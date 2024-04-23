# frozen_string_literal: true

require "spec_helper"

describe "Token codes", type: :system do
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:component) { survey.component }
  let!(:survey) { create(:survey) }
  let!(:existing_group) { create(:anonymous_codes_group, title: { en: "Existing group" }, organization: organization, resource: survey) }
  let!(:existing_empty_group) { create(:anonymous_codes_group, title: { en: "Existing empty group" }, organization: organization, resource: survey) }
  let!(:anonymous_codes_token1) { create(:anonymous_codes_token, group: existing_group) }
  let!(:anonymous_codes_token2) { create(:anonymous_codes_token, :used, group: existing_group) }
  let(:last_token) { Decidim::AnonymousCodes::Token.last }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_anonymous_codes.code_groups_path

    within find("tr", text: existing_empty_group.title["en"]) do
      expect(page).to have_link("List")
      click_link "List"
    end
  end

  it "generates tokens for access code groups" do
    expect(page).to have_content("Codes for group")
    expect(page).to have_content("Token")
    expect(page).to have_content("Available?")
    expect(page).to have_content("Used?")
    expect(page).to have_content("Num. of uses")

    click_link "Generate new codes"

    fill_in "Number of tokens to generate", with: 10
    perform_enqueued_jobs do
      click_on "Generate Tokens"
    end

    expect(page).to have_content("Codes are being generated in the background. Please wait a few seconds and refresh the page.")

    click_link "Back to groups"
    within find("tr", text: "Existing empty group") do
      expect(page).to have_content("0 / 10")
    end
    within find("tr", text: "Existing group") do
      expect(page).to have_content("1 / 2")
    end
  end

  it "destroys an existing token code" do
    click_link "Generate new codes"

    fill_in "Number of tokens to generate", with: 5

    perform_enqueued_jobs do
      click_on "Generate Tokens"
    end

    expect(page).to have_content(last_token.reload.token)

    within find("tr", text: last_token.reload.token) do
      expect(page).to have_link("Delete")
      accept_confirm do
        click_link "Delete", match: :first
      end
    end

    expect(page).to have_content("Access code token successfully destroyed")
  end

  it "allows sorting columns" do
    click_link "Generate new codes"

    fill_in "Number of tokens to generate", with: 15

    perform_enqueued_jobs do
      click_on "Generate Tokens"
    end

    within("thead tr") do
      expect(page).to have_css("th:nth-child(1)", text: "Token")
      expect(page).to have_css("th:nth-child(2)", text: "Available?")
      expect(page).to have_css("th:nth-child(3)", text: "Used?")
      expect(page).to have_css("th:nth-child(4)", text: "Num. of uses")
    end

    click_on "Token"
    token_column = all(".table-list tbody tr td:first-child").map(&:text)
    expect(token_column).to eq(token_column.sort)
  end

  context "when some token codes are available and used" do
    let!(:available_token) { create(:anonymous_codes_token) }
    let!(:used_token) { create(:anonymous_codes_token) }
    let!(:mixed_tokens) { create_list(:anonymous_codes_token, 3) }

    before do
      used_token.update(usage_count: used_token.group.max_reuses)
      available_token.update(usage_count: 2)
    end

    it "sorts tokens based on availability and usage" do
      visit decidim_admin_anonymous_codes.code_groups_path

      within find("tr", text: existing_empty_group.title["en"]) do
        expect(page).to have_link("List")
        click_link "List"
      end

      click_on "Available?"

      expect(page.body.index(used_token.token)).to be < page.body.index(available_token.token)
      expect(page).to have_content(used_token.token)
      expect(page).to have_content(available_token.token)

      click_on "Available?"

      expect(page.body.index(available_token.token)).to be < page.body.index(used_token.token)
    end
  end
end
