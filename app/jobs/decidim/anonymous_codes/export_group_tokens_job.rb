# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class ExportGroupTokensJob < ApplicationJob
      include Decidim::PrivateDownloadHelper
      queue_as :exports

      def perform(user, group, format)
        exporter = format == "AnonymousTokensPdf" ? Decidim::AnonymousCodes::Exporters::AnonymousTokensPdf : Decidim::Exporters.find_exporter(format)

        unless exporter
          Rails.logger.error "Cannot export tokens for group #{group.id}: Unknown format: #{format}"
          return
        end

        Rails.logger.info "Exporting tokens for group #{group.id} in #{format} format"

        export_data = exporter.new(group.tokens, TokenSerializer).export
        private_export = attach_archive(export_data, "anonymous_codes_group_#{group.id}_tokens", user)

        ExportMailer.export(user, private_export).deliver_now
      end
    end
  end
end
