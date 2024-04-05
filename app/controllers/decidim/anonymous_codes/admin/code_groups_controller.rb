# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupsController < ApplicationController
        helper_method :groups

        def index; end

        def new
          @form = form(CodeGroupForm).instance
        end

        def create
          @form = form(CodeGroupForm).from_params(params)

          CreateCodeGroup.call(@form, current_organization) do
            on(:ok) do
              flash[:notice] = I18n.t("code_groups.create.success", scope: "decidim.anonymous_codes.admin")
              redirect_to code_groups_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("code_groups.create.invalid", scope: "decidim.anonymous_codes.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(CodeGroupForm).from_model(code_group)
        end

        def update
          @form = form(CodeGroupForm).from_params(params)

          UpdateCodeGroup.call(@form, code_group) do
            on(:ok) do
              flash[:notice] = I18n.t("code_groups.update.success", scope: "decidim.anonymous_codes.admin")
              redirect_to code_groups_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("code_groups.update.invalid", scope: "decidim.anonymous_codes.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          Decidim.traceability.perform_action!("delete", code_group, current_user) do
            code_group.destroy!
          end

          flash[:notice] = I18n.t("code_groups.destroy.success", scope: "decidim.anonymous_codes.admin")

          redirect_to code_groups_path
        end

        private

        def groups
          AnonymousCodes::Group.for(current_organization)
        end

        def code_group
          @code_group ||= groups.find(params[:id])
        end
      end
    end
  end
end
