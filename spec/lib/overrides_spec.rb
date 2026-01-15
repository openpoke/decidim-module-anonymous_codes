# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-surveys",
    files: {
      "/app/controllers/decidim/surveys/surveys_controller.rb" => "5da988772bbe4236f803325e72c9d54f"
    }
  },
  {
    package: "decidim-forms",
    files: {
      "/app/controllers/decidim/forms/concerns/has_questionnaire.rb" => "6c90ce0a5f3409a4ed9262554feae485",
      "/app/views/decidim/forms/questionnaires/show.html.erb" => "a74645405db3bf02f2897709031e9603"
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
