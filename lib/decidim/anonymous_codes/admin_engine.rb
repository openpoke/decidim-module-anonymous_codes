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
        resources :code_groups do
          resources :codes, only: [:index, :new, :create, :destroy] do
            post :export, on: :collection
          end
        end
        root to: "code_groups#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_decidim-anonymous_codes.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::AnonymousCodes::AdminEngine, at: "/admin/anonymous_codes", as: "decidim_admin_anonymous_codes"
        end
      end

      initializer "decidim-anonymous_codes.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :anonymous_codes_menu,
                        I18n.t("menu_title", scope: "decidim.anonymous_codes.admin"),
                        decidim_admin_anonymous_codes.code_groups_path,
                        icon_name: "hard-drive",
                        position: 7.5,
                        active: is_active_link?(decidim_admin_anonymous_codes.code_groups_path, :inclusive),
                        if: defined?(current_user) && current_user&.read_attribute("admin")
        end
      end
    end
  end
end
