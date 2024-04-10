# frozen_string_literal: true

if ENV["SIMPLECOV"]
  SimpleCov.start do
    root ENV.fetch("ENGINE_ROOT", nil)

    add_filter "lib/decidim/anonymous_codes/version.rb"
    add_filter "lib/decidim/anonymous_codes/test"
    add_filter "/spec"
  end

  SimpleCov.command_name ENV.fetch("COMMAND_NAME", nil) || File.basename(Dir.pwd)

  SimpleCov.merge_timeout 1800

  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
end