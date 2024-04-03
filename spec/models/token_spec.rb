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

      context "when created" do
        let!(:token) { create(:anonymous_codes_token) }

        it "can be destroyed" do
          expect { token.destroy }.to change(Token, :count).by(-1)
        end

        context "and has been used" do
          let!(:token) { create(:anonymous_codes_token, usage_count: 1) }

          it "cannot be destroyed" do
            expect { token.destroy }.not_to change(Token, :count)
          end
        end
      end
    end
  end
end
