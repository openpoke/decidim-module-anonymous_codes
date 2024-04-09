# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    describe Group do
      subject { group }

      let(:group) { create(:anonymous_codes_group) }

      describe "associations" do
        it { expect(described_class.reflect_on_association(:tokens).macro).to eq(:has_many) }
        it { expect(described_class.reflect_on_association(:organization).macro).to eq(:belongs_to) }
      end

      it "has an empty counter cache" do
        expect(group.tokens_count).to eq(0)
      end

      context "when tokens exist" do
        let!(:token) { create(:anonymous_codes_token, group: group) }

        it "has an organization" do
          expect(group.organization).to be_a(Decidim::Organization)
        end

        it "has a counter cache" do
          expect(group.tokens_count).to eq(1)
        end

        it "lowers the counter on destroying tokens" do
          expect { token.destroy }.to change(group, :tokens_count).by(-1)
        end

        it "destroys the tokens when destroyed" do
          expect { group.destroy }.to change(Token, :count).by(-1)
        end

        context "and tokens have been used" do
          let!(:token) { create(:anonymous_codes_token, usage_count: 1, group: group) }

          it "does not destroy the tokens when destroyed" do
            expect { group.destroy }.not_to change(Token, :count)
          end
        end
      end
    end
  end
end
