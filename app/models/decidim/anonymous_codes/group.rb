# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class Group < ApplicationRecord
      self.table_name = :decidim_anonymous_codes_groups

      # prevent destroying if tokens have been used
      before_destroy do
        throw(:abort) if tokens.where(usage_count: 1..Float::INFINITY).count.positive?
      end

      has_many :tokens, class_name: "Decidim::AnonymousCodes::Token", dependent: :destroy
      belongs_to :resource, polymorphic: true, optional: true
    end
  end
end
