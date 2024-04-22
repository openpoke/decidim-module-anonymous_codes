# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class ExportGroupTokensJob < ApplicationJob
      queue_as :exports

      def perform(user, group, format)
        exporter = format == "AnonymousTokensPdf" ? Decidim::AnonymousCodes::Exporters::AnonymousTokensPdf : Decidim::Exporters.find_exporter(format)

        if exporter
          Rails.logger.info "Exporting tokens for group #{group.id} in #{format} format"
        else
          Rails.logger.error "Cannot export tokens for group #{group.id}: Unknown format: #{format}"
        end

        export_data = exporter.new(group.tokens, TokenSerializer).export

        ExportMailer.export(user, "tokens_for_group_#{group.id}", export_data).deliver_now
      end
    end
  end
end
