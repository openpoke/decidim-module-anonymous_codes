# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    # This is the engine that runs on the public interface of decidim-anonymous_codes.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AnonymousCodes

      initializer "decidim_anonymous_codes.overrides", after: "decidim.action_controller" do
        # config.to_prepare do

        # end
      end

      initializer "decidim-anonymous_codes.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
