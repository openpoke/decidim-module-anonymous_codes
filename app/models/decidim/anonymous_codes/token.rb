# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class Token < ApplicationRecord
      self.table_name = :decidim_anonymous_codes_tokens

      # prevent destroying if token has been used
      before_destroy do
        throw(:abort) if usage_count.positive?
      end

      belongs_to :group, class_name: "Decidim::AnonymousCodes::Group"
      belongs_to :resource, polymorphic: true, optional: true
    end
  end
end
