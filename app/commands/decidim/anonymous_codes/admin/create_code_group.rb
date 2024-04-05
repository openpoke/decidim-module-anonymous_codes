# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CreateCodeGroup < Decidim::Command
        def initialize(form, organization)
          @form = form
          @organization = organization
        end

        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_code_group
          end

          broadcast(:ok)
        end

        private

        attr_reader :code_group, :form

        def create_code_group
          @code_group = Decidim.traceability.create!(
            Group,
            @form.current_user,
            title: form.title,
            expires_at: form.expires_at,
            active: form.active,
            max_reuses: form.max_reuses,
            organization: @organization
          )
        end
      end
    end
  end
end
