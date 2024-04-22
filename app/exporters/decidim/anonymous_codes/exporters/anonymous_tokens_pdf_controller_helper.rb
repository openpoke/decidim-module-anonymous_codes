# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Exporters
      # rubocop: disable Rails/ApplicationController
      # A dummy controller to render views while exporting questionnaires
      class AnonymousTokensPdfControllerHelper < ActionController::Base
        # rubocop: enable Rails/ApplicationController
        helper Decidim::TranslationsHelper
      end
    end
  end
end
