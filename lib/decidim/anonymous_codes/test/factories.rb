# frozen_string_literal: true

FactoryBot.define do
  factory :anonymous_codes_group, class: "Decidim::AnonymousCodes::Group" do
    title { { en: "Group title" } }
    organization { create(:organization) }
    expires_at { 1.week.from_now }
    active { true }
    max_reuses { 1 }
    resource { create(:survey) }

    trait :with_used_tokens do
      after(:create) do |group|
        create(:anonymous_codes_token, :used, group: group)
      end
    end
  end

  factory :anonymous_codes_token, class: "Decidim::AnonymousCodes::Token" do
    token { Decidim::AnonymousCodes.token_generator }
    group { create(:anonymous_codes_group) }

    trait :used do
      after(:create) do |object|
        object.token_resources << create(:anonymous_codes_token_resource, token: object)
      end
    end
  end

  factory :anonymous_codes_token_resource, class: "Decidim::AnonymousCodes::TokenResource" do
    token { create(:anonymous_codes_token) }
    resource { create(:answer, questionnaire: token.group.resource.questionnaire) }
  end
end
