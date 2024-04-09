# frozen_string_literal: true

require "spec_helper"

describe "Access codes admin menu", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "adds a new access code group" do
    visit decidim_admin_anonymous_codes.code_groups_path

    click_on "New access code group"

    fill_in_i18n(
      :code_group_title,
      "#code_group-title-tabs",
      en: "New Group",
      es: "NuevoGrupo",
      ca: "Nou group"
    )
    fill_in "Expires At", with: (Time.zone.today + 1.day).strftime("%d/%m/%Y %H:%M")
    check "Active"
    fill_in "Re-use max", with: 10

    click_on "create"

    expect(page).to have_content("Access code group successfully created")
    expect(page).to have_content("New access code group")

    click_link "Edit"
    fill_in_i18n(
      :code_group_title,
      "#code_group-title-tabs",
      en: "My new Group",
      es: "Mi nuevo Grupo",
      ca: "El meu nou Group"
    )
    fill_in "Re-use max", with: 2

    click_on "update"

    expect(page).to have_content("Access code group successfully updated")
    within "table" do
      expect(page).to have_content("My new Group")
    end
  end
end
