# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class TokensForm < Decidim::Form
        attribute :num_tokens, Integer, default: 1

        validates :token_code
      end
    end
  end
end
