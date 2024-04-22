# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    class CreateTokensJob < ApplicationJob
      def perform(code_group, num_tokens)
        @code_group = code_group
        num_tokens.times do
          create_token!
        end
      end

      private

      attr_reader :code_group

      def create_token!
        token = new_token while token.blank?
        token.save!
      end

      def new_token
        token = Decidim::AnonymousCodes::Token.new(
          token: Decidim::AnonymousCodes.token_generator,
          group: code_group
        )
        token if token.valid?
      end
    end
  end
end
