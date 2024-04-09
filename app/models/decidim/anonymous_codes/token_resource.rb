# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class TokenResource < ApplicationRecord
      self.table_name = :decidim_anonymous_codes_token_resources

      belongs_to :token, class_name: "Decidim::AnonymousCodes::Token", counter_cache: :usage_count
      belongs_to :resource, polymorphic: true

      validate :max_uses_not_exceeded
      validate :valid_parent_questionnaire

      private

      def max_uses_not_exceeded
        return unless token.usage_count >= token.group.max_reuses

        errors.add(:base, :max_uses_exceeded)
      end

      def valid_parent_questionnaire
        return unless resource.try(:questionnaire) != token.group.resource.try(:questionnaire)

        errors.add(:base, :invalid_questionnaire)
      end
    end
  end
end
