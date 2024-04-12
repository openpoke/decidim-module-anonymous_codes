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
        attribute :resource_id, Integer

        validates :title, translatable_presence: true
        validates :expires_at, date: { after: Date.current }, if: ->(form) { form.expires_at.present? }
        validates :max_reuses, presence: true, numericality: { only_integer: true, greater_than: 0 }

        def resource
          @resource ||= Decidim::Surveys::Survey.find_by(id: resource_id)
        end
      end
    end
  end
end
