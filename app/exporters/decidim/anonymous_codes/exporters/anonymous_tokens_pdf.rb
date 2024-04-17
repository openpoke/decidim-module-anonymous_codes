# frozen_string_literal: true

require "wicked_pdf"

module Decidim
  module AnonymousCodes
    module Exporters
      # Inherits from abstract PDF exporter. This class is used to set
      # the parameters used to create a PDF when exporting Survey Answers.
      #
      class AnonymousTokensPdf < Decidim::Exporters::PDF
        def controller
          @controller ||= AnonymousTokensPdfControllerHelper.new
        end

        def template
          "decidim/anonymous_codes/admin/export/tokens_pdf"
        end

        def layout
          "decidim/anonymous_codes/admin/export/pdf"
        end

        def locals
          {
            code_group: collection&.first&.group,
            collection: collection.map { |token| Decidim::AnonymousCodes::TokenSerializer.new(token).serialize }
          }
        end
      end
    end
  end
end
