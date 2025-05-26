# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-surveys",
    files: {
      "/app/controllers/decidim/surveys/surveys_controller.rb" => "161ca4167c381f3ba93d86431c10710b"
    }
  },
  {
    package: "decidim-forms",
    files: {
      "/app/controllers/decidim/forms/concerns/has_questionnaire.rb" => "1e9ed3defacdbbc67aa03e6dde5f1b4c",
      "/app/views/decidim/forms/questionnaires/show.html.erb" => "e2dffec30b86fa0f9fd892d704d6fd2a"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
