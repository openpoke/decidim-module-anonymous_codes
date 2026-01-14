# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class ExportGroupTokensJob < ApplicationJob
      queue_as :exports

      def perform(user, group, format)
        exporter = format == "AnonymousTokensPdf" ? Decidim::AnonymousCodes::Exporters::AnonymousTokensPdf : Decidim::Exporters.find_exporter(format)

        unless exporter
          Rails.logger.error "Cannot export tokens for group #{group.id}: Unknown format: #{format}"
          return
        end

        Rails.logger.info "Exporting tokens for group #{group.id} in #{format} format"

        export_data = exporter.new(group.tokens, TokenSerializer).export
        export_for_mailer = Struct.new(:file_name, :content_type, :data, :export_type, :expires_at).new(
          "tokens_for_group_#{group.id}.pdf",
          "application/pdf",
          export_data,
          format,
          1.week.from_now
        )

        ExportMailer.export(user, export_for_mailer).deliver_now
      end
    end
  end
end
