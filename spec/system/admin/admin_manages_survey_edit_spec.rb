# frozen_string_literal: true

require "spec_helper"

describe "Admin manages survey edit" do
  let!(:component) { create(:surveys_component) }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire:) }
  let!(:survey) { create(:survey, :published, component:, questionnaire:) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let(:group) { create(:anonymous_codes_group, organization:, resource:) }
  let!(:token) { create(:anonymous_codes_token, group:) }
  let(:resource) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::EngineRouter.admin_proxy(component).edit_survey_path(survey)
  end

  it "has callout" do
    within ".callout.warning" do
      expect(page).to have_content("Create answer codes here")
    end
  end

  context "when codes are available" do
    let(:resource) { survey }

    it "has callout" do
      within ".callout.alert" do
        expect(page).to have_content("This survey can only be answered by using a valid code")
      end
    end
  end
end
