# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class ApplicationController < Decidim::Admin::ApplicationController
        def permission_class_chain
          [::Decidim::AnonymousCodes::Admin::Permissions] + super
        end
      end
    end
  end
end
