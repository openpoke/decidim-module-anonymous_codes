# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class TokensForm < Decidim::Form
        attribute :token, String

        validates :token, presence: true

        validate :token_matches_regexp

        def token
          attributes[:token].to_s.upcase
        end

        private

        def token_matches_regexp
          errors.add(:token, I18n.t("errors.messages.uppercase_only_letters_numbers")) unless token.match(/#{AnonymousCodes.manual_token_regexp}/)
        end
      end
    end
  end
end
