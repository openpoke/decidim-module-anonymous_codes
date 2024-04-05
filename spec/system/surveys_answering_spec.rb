# frozen_string_literal: true

require "spec_helper"

describe "Surveys Component Settings", type: :system do
  let(:organization) { component.organization }
  let(:component) { survey.component }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:another_user) { create :user, :confirmed, organization: organization }
  let(:group) { create :anonymous_codes_group, organization: organization, expires_at: expires, resource: resource, active: active }
  let!(:token) { create :anonymous_codes_token, group: group }
  let!(:another_token) { create :anonymous_codes_token }
  let(:active) { true }
  let(:expires) { nil }
  let(:survey) { create(:survey, questionnaire: questionnaire) }
  let(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, body: { en: "What's the meaning of life?" }, mandatory: true, question_type: :short_answer, questionnaire: questionnaire) }
  let(:resource) { survey }
  let(:code) { token.token }
  let(:settings) do
    {
      allow_answers: true,
      allow_unregistered: allow_unregistered
    }
  end
  let(:allow_unregistered) { false }

  def visit_component
    visit Decidim::EngineRouter.main_proxy(component).survey_path(component.id)
  end

  before do
    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => settings
      }
    )

    switch_to_host(organization.host)
  end

  shared_examples "form is restricted" do
    it "shows the restricted message" do
      expect(page).to have_content("Form restricted")
      expect(page).to have_field("token")
    end
  end

  shared_examples "form is readonly" do
    it "sends the code" do
      fill_in :token, with: code
      click_button("Continue")
      expect(page).to have_content(question.body["en"])
      expect(page).to have_link("Sign in with your account")
      expect(page).not_to have_button("Submit")
    end
  end

  shared_examples "form is enabled" do
    it "sends the code and the form" do
      fill_in :token, with: code
      click_button("Continue")

      expect(token).not_to be_used

      fill_in question.body["en"], with: "42"
      check "questionnaire_tos_agreement"
      accept_confirm { click_button "Submit" }
      expect(page).to have_css(".callout.success")
      expect(page).to have_content("Already answered")

      expect(token.reload).to be_used
    end
  end

  shared_examples "can be answered without codes" do
    it "sends the form" do
      expect(token).not_to be_used

      fill_in question.body["en"], with: "42"
      check "questionnaire_tos_agreement"
      accept_confirm { click_button "Submit" }
      expect(page).to have_css(".callout.success")
      expect(page).to have_content("Already answered")

      expect(token.reload).not_to be_used
    end
  end

  shared_examples "can be answered with codes" do
    it_behaves_like "form is enabled"

    context "and code group is inactive" do
      let(:active) { false }

      it_behaves_like "can be answered without codes"
    end

    context "and code re-uses have exceeded" do
      let!(:token) { create :anonymous_codes_token, group: group, answers: [create(:answer, questionnaire: questionnaire, user: another_user)] }

      it "sends the code and fails" do
        fill_in :token, with: code
        click_button("Continue")
        expect(page).to have_css(".callout.alert")
        expect(page).to have_content("The introduced code has already been used.")
        expect(page).to have_content("Form restricted")
        expect(page).to have_field("token")
        expect(page).not_to have_content(question.body["en"])
      end
    end

    context "and group has an expiration" do
      let(:expires) { 1.hour.from_now }

      it_behaves_like "form is enabled"
    end

    context "and group has expired" do
      let(:expires) { 1.minute.ago }

      it "sends the code and fails" do
        fill_in :token, with: code
        click_button("Continue")
        expect(page).to have_css(".callout.alert")
        expect(page).to have_content("The introduced code has expired.")
        expect(page).to have_content("Form restricted")
        expect(page).to have_field("token")
        expect(page).not_to have_content(question.body["en"])
      end
    end
  end

  shared_examples "cannot be answered with bad codes" do
    it "sends the code and fails" do
      fill_in :token, with: "dirty-things"
      click_button("Continue")
      expect(page).to have_css(".callout.alert")
      expect(page).to have_content("The introduced code is invalid.")
      expect(page).to have_content("Form restricted")
      expect(page).to have_field("token")
      expect(page).not_to have_content(question.body["en"])
    end

    it "sends another code and fails" do
      fill_in :token, with: another_token.token
      click_button("Continue")
      expect(page).to have_css(".callout.alert")
      expect(page).to have_content("The introduced code is invalid.")
      expect(page).to have_content("Form restricted")
      expect(page).to have_field("token")
      expect(page).not_to have_content(question.body["en"])
    end
  end

  context "when user is not logged" do
    before do
      visit_component
    end

    it_behaves_like "form is restricted"
    it_behaves_like "form is readonly"

    context "and login is not required" do
      let(:allow_unregistered) { true }

      it_behaves_like "can be answered with codes"
      it_behaves_like "cannot be answered with bad codes"

      context "and there are no codes required" do
        let(:resource) { nil }

        it_behaves_like "can be answered without codes"
      end
    end
  end

  context "when user is logged" do
    before do
      login_as user, scope: :user
      visit_component
    end

    it_behaves_like "form is restricted"
    it_behaves_like "can be answered with codes"
    it_behaves_like "cannot be answered with bad codes"

    context "and there are no codes required" do
      let(:resource) { nil }

      it_behaves_like "can be answered without codes"
    end
  end
end
