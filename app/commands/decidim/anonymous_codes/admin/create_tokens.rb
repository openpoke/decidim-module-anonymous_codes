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

          CreateTokensJob.perform_later(code_group, form.num_tokens)

          broadcast(:ok)
        end

        private

        attr_reader :form, :code_group
      end
    end
  end
end
