# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodesController < ApplicationController
        include Decidim::Admin::Paginable
        include TranslatableAttributes

        helper_method :tokens, :code_group, :export_manifests

        def index
          @tokens = paginate(tokens.order(created_at: :desc))
        end

        def new
          # todo
        end

        def create
          # todo
        end

        def destroy
          # todo
        end

        private

        def tokens
          AnonymousCodes::Token.for(code_group)
        end

        def code_group
          @code_group ||= AnonymousCodes::Group.for(current_organization).find(params[:code_group_id])
        end

        def export_manifests
          @export_manifests ||= [
            Decidim::Exporters::ExportManifest.new(:all_tokens, "export_all").tap do |manifest|
              manifest.formats(Decidim::AnonymousCodes.export_formats)
              manifest.collection do
                tokens
              end
            end
          ]
        end
      end
    end
  end
end
