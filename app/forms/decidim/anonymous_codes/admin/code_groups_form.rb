# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupsForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        attribute :expires_at, Decidim::Attributes::LocalizedDate
        attribute :active, Boolean
        attribute :max_reuses, Integer

        validates :expires_at, presence: true
        validates :title, translatable_presence: true
      end
    end
  end
end
