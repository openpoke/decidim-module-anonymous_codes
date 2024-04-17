# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CreateTokens < Decidim::Command
        def initialize(form, code_group)
          @form = form
          @code_group = code_group
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            form.num_tokens.times do
              create_token!
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :code_group

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
end
