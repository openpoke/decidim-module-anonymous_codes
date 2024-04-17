# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CodeForm < Decidim::Form
        include TranslatableAttributes

        attribute :tokens, Integer, default: 1

        validates :tokens, presence: true, numericality: { only_integer: true, greater_than: 0 }
      end
    end
  end
end
