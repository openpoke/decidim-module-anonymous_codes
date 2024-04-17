# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodesController < ApplicationController
        include Decidim::Admin::Paginable
        include TranslatableAttributes

        helper_method :tokens, :code_group

        def index
          enforce_permission_to :view, :anonymous_code_token

          @tokens = paginate(tokens.order(created_at: :desc))
        end

        def new
          enforce_permission_to :create, :anonymous_code_token

          @form = form(TokensForm).instance
        end

        def create
          enforce_permission_to :create, :anonymous_code_token

          @form = form(TokensForm).from_params(params)

          CreateTokens.call(@form, code_group) do
            on(:ok) do
              flash[:notice] = I18n.t("codes.create.success", scope: "decidim.anonymous_codes.admin")
              redirect_to code_group_codes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("codes.create.invalid", scope: "decidim.anonymous_codes.admin")
              render action: "new"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :anonymous_code_token, token: token
          token.destroy!

          flash[:notice] = I18n.t("codes.destroy.success", scope: "decidim.anonymous_codes.admin")

          redirect_to code_group_codes_path
        end

        private

        def tokens
          AnonymousCodes::Token.where(group: code_group)
        end

        def token
          tokens.find(params[:id])
        end

        def code_group
          @code_group ||= AnonymousCodes::Group.for(current_organization).find(params[:code_group_id])
        end
      end
    end
  end
end
