# frozen_string_literal: true

require "decidim/anonymous_codes/engine"
require "decidim/anonymous_codes/admin_engine"

module Decidim
  # This namespace holds the logic of the `decidim-anonymous_codes` module.
  module AnonymousCodes
    include ActiveSupport::Configurable
  end
end
