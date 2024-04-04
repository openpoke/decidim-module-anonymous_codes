# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupsController < ApplicationController
        helper_method :groups

        def index; end

        def new
          @form = form(CodeGroupsForm).instance
        end

        def create; end

        def edit; end

        def update; end

        def destroy; end

        private

        def groups
          AnonymousCodes::Group.for(current_organization)
        end
      end
    end
  end
end
