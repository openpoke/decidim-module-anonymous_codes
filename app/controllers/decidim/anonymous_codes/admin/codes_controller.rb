# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodesController < ApplicationController
        include Decidim::Admin::Paginable
        include TranslatableAttributes
        include Decidim::AnonymousCodes::Admin::Filterable

        helper_method :tokens, :code_group, :export_jobs

        def index
          enforce_permission_to :view, :anonymous_code_token

          @tokens = paginate(tokens.order(created_at: :desc))
        end

        def collection
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

        def export
          enforce_permission_to :export, :anonymous_code_token

          if export_jobs[export_name].present?
            Decidim.traceability.perform_action!("export_anonymous_codes_tokens", code_group, current_user, { name: export_name, format: export_format }) do
              export_jobs[export_name].perform_later(current_user, code_group, export_format)
            end

            flash[:notice] = t("decidim.admin.exports.notice")
          end

          redirect_back(fallback_location: code_group_codes_path(code_group))
        end

        private

        def tokens
          AnonymousCodes::Token.for(code_group)
        end

        def token
          @token ||= tokens.find(params[:id])
        end

        def code_group
          @code_group ||= AnonymousCodes::Group.for(current_organization).find(params[:code_group_id])
        end

        def export_jobs
          { "all_tokens" => ExportGroupTokensJob }
        end

        def export_format
          params[:format] || "json"
        end

        def export_name
          params[:name] || "all_tokens"
        end
      end
    end
  end
end
