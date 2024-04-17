# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    # This class serializes a Token so can be exported to CSV, JSON or other formats.
    class TokenSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a token.
      def initialize(token)
        @token = token
      end

      # Public: Exports a hash with the serialized data for this token.
      def serialize
        {
          token: token.token,
          resource_url: resource_url,
          resource_type: token.group.resource_type,
          resource_id: token.group.resource_id,
          group: translated_attribute(token.group.title),
          available: token.available?,
          used: token.used?,
          usage_count: token.usage_count,
          expired: token.expired?,
          expires_at: token.group.expires_at.present? ? I18n.l(token.group.expires_at, format: :decidim_short) : nil,
          created_at: I18n.l(token.created_at, format: :decidim_short)
        }
      end

      private

      attr_reader :token

      def resource_url
        return nil unless token.group.resource

        Decidim::ResourceLocatorPresenter.new(token.group.resource).url(token: token.token)
      end
    end
  end
end
