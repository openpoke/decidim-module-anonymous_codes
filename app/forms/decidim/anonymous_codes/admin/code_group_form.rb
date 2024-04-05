# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :expires_at, Decidim::Attributes::LocalizedDate
        attribute :active, Boolean, default: true
        attribute :max_reuses, Integer, default: 1

        validates :max_reuses, presence: true
        validates :title, translatable_presence: true
      end
    end
  end
end
