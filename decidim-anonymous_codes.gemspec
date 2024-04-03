# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/anonymous_codes/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-anonymous_codes"
  spec.version = Decidim::AnonymousCodes::VERSION
  spec.authors = ["Ivan Vergés"]
  spec.email = ["ivan@pokecode.net"]

  spec.summary = "Allow annonymous users to answer surveys using specific assigned tokens"
  spec.description = "Allow annonymous users to answer surveys using specific assigned tokens"
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/openpoke/decidim-module-anonymous_codes"
  spec.required_ruby_version = ">= 3.0"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::AnonymousCodes::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::AnonymousCodes::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-surveys", Decidim::AnonymousCodes::COMPAT_DECIDIM_VERSION
  spec.add_dependency "deface", ">= 1.9.0"

  spec.add_development_dependency "decidim-dev", Decidim::AnonymousCodes::COMPAT_DECIDIM_VERSION
  spec.metadata["rubygems_mfa_required"] = "true"
end
