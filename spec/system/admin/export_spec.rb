# frozen_string_literal: true

require "spec_helper"

describe "Export codes", type: :system do
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:component) { survey.component }
  let!(:survey) { create(:survey) }
  let!(:group) { create(:anonymous_codes_group, organization: organization, resource: survey) }
  let!(:token1) { create(:anonymous_codes_token, group: group) }
  let!(:token2) { create(:anonymous_codes_token, group: group) }
  let!(:token3) { create(:anonymous_codes_token, :used, group: group) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_anonymous_codes.code_group_codes_path(group)
  end

  it "shows the export dropdown" do
    within ".card-title" do
      find("span", text: "Export all").click

      expect(page).to have_content("All tokens as CSV")
      expect(page).to have_content("All tokens as Excel")
      expect(page).to have_content("All tokens as JSON")
      expect(page).to have_content("All tokens as PDF")
    end
  end

  shared_examples "exports as" do |method, extension|
    it "can export as #{method}" do
      click_link "All tokens as #{method}"
      perform_enqueued_jobs

      expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
      expect(last_email.subject).to include("tokens_for_group_#{group.id}", extension)
      expect(last_email.attachments.length).to be_positive
      expect(last_email.attachments.first.filename).to match(/^tokens_for_group_#{group.id}.*\.zip$/)
    end
  end

  context "when exporting" do
    before do
      within ".card-title" do
        find("span", text: "Export all").click
      end
    end

    it_behaves_like "exports as", "CSV", "csv"
    it_behaves_like "exports as", "JSON", "json"
    it_behaves_like "exports as", "Excel", "xlsx"
    it_behaves_like "exports as", "PDF", "pdf"
  end
end
