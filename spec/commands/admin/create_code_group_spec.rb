# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    describe Group, type: :model do
      let(:current_organization) { create(:organization) }

      describe "#create" do
        it "creates a code group successfully" do
          code_group = Decidim::AnonymousCodes::Group.create(
            title: "Sample Code Group",
            expires_at: 10.days.from_now,
            active: true,
            max_reuses: 10,
            organization: current_organization
          )

          expect(code_group).to be_valid
        end
      end
    end
  end
end
