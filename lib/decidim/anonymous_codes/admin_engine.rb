# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    # This is the admin interface for `decidim-blogs`. It lets you edit and
    # configure the blog associated to a participatory process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::AnonymousCodes::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :code_groups
        root to: "code_groups#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_decidim_awesome.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DecidimAwesome::AdminEngine, at: "/admin/decidim_awesome", as: "decidim_admin_decidim_awesome"
        end
      end

      initializer "decidim_awesome.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :awesome_menu,
                        I18n.t("menu.decidim_awesome", scope: "decidim.admin"),
                        decidim_admin_decidim_awesome.config_path(:editors),
                        icon_name: "fire",
                        position: 7.5,
                        active: is_active_link?(decidim_admin_decidim_awesome.config_path(:editors), :inclusive),
                        if: defined?(current_user) && current_user&.read_attribute("admin")
        end
      end
    end
  end
end
