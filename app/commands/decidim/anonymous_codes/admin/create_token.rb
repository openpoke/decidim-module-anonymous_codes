# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CreateToken < Decidim::Command
        def initialize(form, code_group)
          @form = form
          @code_group = code_group
        end

        def call
          return broadcast(:invalid) if form.invalid?

          Token.create!(group: code_group, token: form.token)
          broadcast(:ok)
        end

        private

        attr_reader :form, :code_group
      end
    end
  end
end
