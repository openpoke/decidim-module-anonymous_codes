# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class TokensForm < Decidim::Form
        attribute :num_tokens, Integer, default: 1

        validates :num_tokens, presence: true, numericality: { only_integer: true, greater_than: 0 }
      end
    end
  end
end
