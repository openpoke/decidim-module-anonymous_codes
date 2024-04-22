# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeGroupForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :expires_at, Decidim::Attributes::TimeWithZone
        attribute :active, Boolean, default: true
        attribute :max_reuses, Integer, default: 1
        attribute :resource_id, Integer
        attribute :num_tokens, Integer

        validates :title, translatable_presence: true
        validates :expires_at, date: { after: Time.current }, if: ->(form) { form.expires_at.present? && form.active }
        validates :max_reuses, presence: true, numericality: { only_integer: true, greater_than: 0 }
        validates :num_tokens, numericality: { only_integer: true, greater_than: 0 }, if: ->(form) { form.num_tokens.present? }

        def resource
          @resource ||= Decidim::Surveys::Survey.find_by(id: resource_id)
        end
      end
    end
  end
end
