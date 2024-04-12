# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user&.admin?

          anonymous_codes_group_action?

          permission_action
        end

        private

        def anonymous_codes_group_action?
          return unless permission_action.subject == :anonymous_code_group

          allow! if permission_action.action.in?([:create, :update, :destroy, :export])
        end
      end
    end
  end
end
