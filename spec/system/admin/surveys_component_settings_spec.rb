# frozen_string_literal: true

require "spec_helper"

describe "Surveys Component Settings", type: :system do
  let(:organization) { component.organization }
  let(:component) { survey.component }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:group) { create :anonymous_codes_group, organization: organization, resource: resource }
  let!(:token) { create :anonymous_codes_token, group: group }
  let!(:survey) { create(:survey) }
  let(:resource) { nil }

  def visit_component
    visit Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component
  end

  it "has callout" do
    within ".callout.warning" do
      expect(page).to have_content("Create answer codes here")
      expect(page).to have_content("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
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

  context "when not a surveys component" do
    let(:component) { create :proposal_component }

    it "has no callout" do
      expect(page).not_to have_css(".callout")
    end
  end
end
