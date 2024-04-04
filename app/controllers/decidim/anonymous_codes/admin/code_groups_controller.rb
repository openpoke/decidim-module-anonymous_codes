# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupsController < ApplicationController
        helper_method :groups

        def index; end

        def new; end

        def create; end

        private

        def groups
          AnonymousCodes::Group.for(current_organization)
        end
      end
    end
  end
end
