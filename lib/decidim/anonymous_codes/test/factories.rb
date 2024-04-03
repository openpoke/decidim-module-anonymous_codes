# frozen_string_literal: true

FactoryBot.define do
  factory :anonymous_codes_group, class: "Decidim::AnonymousCodes::Group" do
    title { { en: "Group title" } }
    expires_at { 1.week.from_now }
    active { true }
    max_reuses { 1 }
    resource { create(:survey) }
  end

  factory :anonymous_codes_token, class: "Decidim::AnonymousCodes::Token" do
    token { SecureRandom.uuid }
    usage_count { 0 }
    group { create(:anonymous_codes_group) }
  end
end
