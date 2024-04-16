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
          AnonymousCodes::Token.where(group: code_group)
        end

        def code_group
          @code_group ||= AnonymousCodes::Group.for(current_organization).find(params[:code_group_id])
        end
      end
    end
  end
end
