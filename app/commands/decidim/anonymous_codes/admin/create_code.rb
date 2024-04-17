# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module Admin
      class CreateCode < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
        end
      end
    end
  end
end
