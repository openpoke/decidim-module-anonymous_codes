# frozen_string_literal: true

Rake::Task["decidim:choose_target_plugins"].enhance do
  ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_anonymous_codes"
end

namespace :decidim_anonymous_codes do
  namespace :db do
    desc "loads all seeds in db/seeds.rb"
    task seed: :environment do
      Decidim::AnonymousCodes::Engine.load_seed
    end
  end
end
