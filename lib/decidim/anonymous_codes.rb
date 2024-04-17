# frozen_string_literal: true

require "decidim/anonymous_codes/admin"
require "decidim/anonymous_codes/engine"
require "decidim/anonymous_codes/admin_engine"

module Decidim
  # This namespace holds the logic of the `decidim-anonymous_codes` module.
  module AnonymousCodes
    include ActiveSupport::Configurable

    config_accessor :default_token_length do
      ENV.fetch("ANONYMOUS_CODES_DEFAULT_TOKEN_LENGTH", 10).to_i
    end

    config_accessor :token_style do
      ENV.fetch("ANONYMOUS_CODES_TOKEN_STYLE", "alphanumeric")
    end

    config_accessor :export_formats do
      ENV.fetch("ANONYMOUS_CODES_EXPORT_FORMATS", "CSV JSON Excel AnonymousTokensPDF").split
    end

    def self.token_generator(length = nil)
      length ||= AnonymousCodes.default_token_length
      case AnonymousCodes.token_style
      when "numeric"
        SecureRandom.random_number(10**length).to_s.rjust(length, "0")
      else
        SecureRandom.alphanumeric(length).upcase
      end
    end
  end

  module Exporters
    autoload :AnonymousTokensPDF, "decidim/exporters/anonymous_tokens_pdf"
    autoload :AnonymousTokensPDFControllerHelper, "decidim/exporters/anonymous_tokens_pdf_controller_helper"
  end
end
