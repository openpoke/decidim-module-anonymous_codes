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
            create_code_group!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :code_group

        def create_code_group!
          Token.create!(group: code_group,
                        token: form.token)
        end
      end
    end
  end
end
