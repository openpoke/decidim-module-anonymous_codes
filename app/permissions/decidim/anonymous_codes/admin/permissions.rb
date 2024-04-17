# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user&.admin?

          anonymous_codes_group_action?
          anonymous_codes_token_action?

          permission_action
        end

        private

        def anonymous_codes_group_action?
          return unless permission_action.subject == :anonymous_code_group

          case permission_action.action
          when :create, :update, :export
            allow!
          when :destroy
            toggle_allow(code_group.destroyable?) if code_group
          end
        end

        def anonymous_codes_token_action?
          return unless permission_action.subject == :anonymous_code_token

          case permission_action.action
          when :view, :create, :export
            allow!
          when :destroy
            toggle_allow(token.destroyable?) if token
          end
        end

        def code_group
          context.fetch(:code_group, nil)
        end

        def token
          context.fetch(:token, nil)
        end
      end
    end
  end
end
