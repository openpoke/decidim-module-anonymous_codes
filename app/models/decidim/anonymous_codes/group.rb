# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class Group < ApplicationRecord
      self.table_name = :decidim_anonymous_codes_groups

      # prevent destroying if tokens have been used
      before_destroy do
        throw(:abort) unless destroyable?
      end

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"
      has_many :tokens, class_name: "Decidim::AnonymousCodes::Token", dependent: :destroy
      belongs_to :resource, polymorphic: true, optional: true

      scope :active, -> { where(active: true) }
      scope :inactive, -> { where(active: false) }

      def self.for(organization)
        where(organization: organization)
      end

      def expired?
        expires? && expires_at < Time.current
      end

      def expires?
        expires_at.present?
      end

      def destroyable?
        tokens.used.count.zero?
      end
    end
  end
end
