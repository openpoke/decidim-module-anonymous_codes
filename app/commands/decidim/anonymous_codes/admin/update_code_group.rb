# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class UpdateCodeGroup < Decidim::Command
        def initialize(form, code_group)
          @form = form
          @code_group = code_group
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_code_group
          end

          broadcast(:ok, code_group)
        end

        private

        attr_reader :code_group, :form

        def update_code_group
          Decidim.traceability.update!(
            code_group,
            form.current_user,
            title: form.title,
            expires_at: form.expires_at,
            active: form.active,
            max_reuses: form.max_reuses
          )
        end
      end
    end
  end
end
