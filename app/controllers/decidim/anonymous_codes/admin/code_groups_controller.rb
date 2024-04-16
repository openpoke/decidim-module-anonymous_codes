# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupsController < ApplicationController
        include Decidim::Admin::Paginable
        include TranslatableAttributes
        helper_method :groups, :resource_path, :surveys

        def index
          @groups = paginate(groups.order(created_at: :desc))
        end

        def new
          @form = form(CodeGroupForm).instance
        end

        def create
          @form = form(CodeGroupForm).from_params(params)

          CreateCodeGroup.call(@form) do
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

        def resource_path(group)
          return nil unless group&.resource

          Decidim::ResourceLocatorPresenter.new(group.resource).path
        end

        def surveys
          @surveys ||= begin
            classes = Decidim.participatory_space_manifests.pluck :model_class_name
            components = []
            classes.each do |klass|
              spaces = klass.safe_constantize.where(organization: current_organization)
              spaces.each do |space|
                components.concat Decidim::Component.where(participatory_space: space).pluck(:id)
              end
            end
            Decidim::Surveys::Survey.where(decidim_component_id: components).map do |survey|
              component = survey.component
              [
                "#{translated_attribute(component.participatory_space.title)} :: #{translated_attribute(component.name)}",
                survey.id
              ]
            end
          end
        end
      end
    end
  end
end
