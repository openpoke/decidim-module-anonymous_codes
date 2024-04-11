# frozen_string_literal: true

require "spec_helper"

describe "Access codes admin menu", type: :system do
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:component) { survey.component }
  let!(:survey) { create(:survey) }

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
    select "#{component.participatory_space.title["en"]} :: #{component.name["en"]}", from: "code_group_resource_id"

    click_on "create"

    expect(page).to have_content("Access code group successfully created")
    expect(page).to have_content("New access code group")
    last_group = Decidim::AnonymousCodes::Group.last
    expect(last_group.title["en"]).to eq("New Group")
    expect(last_group.max_reuses).to eq(10)
    expect(last_group.active).to be(true)

    click_link "Edit"
    fill_in_i18n(
      :code_group_title,
      "#code_group-title-tabs",
      en: "My new Group",
      es: "Mi nuevo Grupo",
      ca: "El meu nou Group"
    )
    fill_in "Re-use max", with: 2
    select "#{component.participatory_space.title["en"]} :: #{component.name["en"]}", from: "code_group_resource_id"

    click_on "update"

    expect(page).to have_content("Access code group successfully updated")
    within "table" do
      expect(page).to have_content("My new Group")
    end
  end

  it "adds a new access code group with nil expiration date" do
    visit decidim_admin_anonymous_codes.code_groups_path

    click_on "New access code group"
    fill_in_i18n(:code_group_title, "#code_group-title-tabs", en: "New Group", es: "Nuevo Grupo", ca: "Nou Grup")
    check "Active"
    fill_in "Re-use max", with: 10
    select "#{component.participatory_space.title["en"]} :: #{component.name["en"]}", from: "code_group_resource_id"

    click_on "create"

    expect(page).to have_content("Access code group successfully created")
    expect(page).to have_content("New access code group")

    last_group = Decidim::AnonymousCodes::Group.last
    expect(last_group.title["en"]).to eq("New Group")
    expect(last_group.max_reuses).to eq(10)
    expect(last_group.active).to be(true)

    visit decidim_admin_anonymous_codes.code_groups_path
    expect(page).to have_content("New Group")
    expect(page).to have_content("Never")
  end
end
