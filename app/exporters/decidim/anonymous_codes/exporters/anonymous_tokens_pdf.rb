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

        def export
          pdf_html = controller.render_to_string(
            template: template,
            layout: layout,
            locals: locals
          )

          pdf_file = WickedPdf.new.pdf_from_string(pdf_html)

          Decidim::Exporters::ExportData.new(pdf_file, nil)
        end
      end
    end
  end
end
