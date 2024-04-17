# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodesController < ApplicationController
        include Decidim::Admin::Paginable
        include TranslatableAttributes

        helper_method :tokens, :code_group

        def index
          @tokens = paginate(tokens.order(created_at: :desc))
        end

        def new
          @form = form(TokensForm).instance
        end

        def create
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
          Decidim.traceability.perform_action!("delete", code_group, token, current_user) do
            token.destroy!
          end

          flash[:notice] = I18n.t("codes.destroy.success", scope: "decidim.anonymous_codes.admin")

          redirect_to code_group_codes_path
        end

        private

        def tokens
          AnonymousCodes::Token.where(group: code_group)
        end

        def token
          tokens.find_by(id: params[:id])
        end

        def code_group
          @code_group ||= AnonymousCodes::Group.for(current_organization).find(params[:code_group_id])
        end
      end
    end
  end
end
