# frozen_string_literal: true

if !Rails.env.production? || ENV.fetch("SEED", nil)
  print "Creating seeds for decidim_anonymous_codes...\n" unless Rails.env.test?

  organization = Decidim::Organization.first

  group1 = Decidim::AnonymousCodes::Group.create!(
    title: { en: "First Group" },
    organization: organization,
    expires_at: 1.week.from_now,
    active: true,
    max_reuses: 1,
    resource: Decidim::Surveys::Survey.first
  )

  group2 = Decidim::AnonymousCodes::Group.create!(
    title: { en: "Second Group" },
    organization: organization,
    expires_at: 1.week.from_now,
    active: true,
    max_reuses: 1,
    resource: Decidim::Surveys::Survey.second
  )

  5.times do
    Decidim::AnonymousCodes::Token.create!(token: Decidim::AnonymousCodes.token_generator, usage_count: 0, group: group1)
  end

  25.times do
    Decidim::AnonymousCodes::Token.create!(token: Decidim::AnonymousCodes.token_generator, usage_count: 0, group: group2)
  end
end
