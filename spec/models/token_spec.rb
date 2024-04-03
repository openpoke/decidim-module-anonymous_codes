# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    describe Token do
      subject { token }

      let(:token) { create(:anonymous_codes_token) }

      describe "associations" do
        it { expect(described_class.reflect_on_association(:group).macro).to eq(:belongs_to) }
      end
    end
  end
end
