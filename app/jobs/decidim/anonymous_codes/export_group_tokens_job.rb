# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class ExportGroupTokensJob < ApplicationJob
      queue_as :exports

      def perform(user, group, format)
        export_data = Decidim::Exporters.find_exporter(format).new(group.tokens, TokenSerializer).export

        ExportMailer.export(user, "tokens_for_group_#{group.id}", export_data).deliver_now
      end
    end
  end
end
