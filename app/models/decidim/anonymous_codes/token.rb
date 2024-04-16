# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class Token < ApplicationRecord
      self.table_name = :decidim_anonymous_codes_tokens

      # prevent destroying if token has been used
      before_destroy do
        throw(:abort) if usage_count.positive?
      end

      belongs_to :group, class_name: "Decidim::AnonymousCodes::Group", counter_cache: true
      has_many :token_resources, class_name: "Decidim::AnonymousCodes::TokenResource", dependent: :destroy
      has_many :answers, through: :token_resources, source_type: "Decidim::Forms::Answer", source: :resource

      delegate :active?, :expired?, to: :group
      validates :token, presence: true
      validates :token, uniqueness: { scope: [:group] }

      scope :used, -> { where("usage_count > 0") }

      def available?
        !used? && !expired? && active?
      end

      def used?
        usage_count.to_i >= group.max_reuses.to_i
      end
    end
  end
end
