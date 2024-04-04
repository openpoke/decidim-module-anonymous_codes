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

      describe "used?" do
        context "when usage_count is 0" do
          it { is_expected.not_to be_used }
        end

        context "when usage_count is 1" do
          let(:token) { create(:anonymous_codes_token, usage_count: 1) }

          it { is_expected.to be_used }

          context "when max_reuses is 2" do
            before do
              token.group.update!(max_reuses: 2)
            end

            it { is_expected.not_to be_used }
          end
        end
      end

      describe "expired?" do
        context "when expires_at is nil" do
          it { is_expected.not_to be_expired }
        end

        context "when expires_at is in the past" do
          before do
            token.group.update!(expires_at: 1.minute.ago)
          end

          it { is_expected.to be_expired }
        end

        context "when expires_at is in the future" do
          before do
            token.group.update!(expires_at: 1.minute.from_now)
          end

          it { is_expected.not_to be_expired }
        end
      end

      describe "active?" do
        it { is_expected.to be_active }

        context "when inactive" do
          before do
            token.group.update!(active: false)
          end

          it { is_expected.not_to be_active }
        end
      end

      describe "available?" do
        it { is_expected.to be_available }

        context "when used" do
          let(:token) { create(:anonymous_codes_token, usage_count: 1) }

          it { is_expected.not_to be_available }
        end

        context "when expired" do
          before do
            token.group.update!(expires_at: 1.minute.ago)
          end

          it { is_expected.not_to be_available }
        end

        context "when inactive" do
          before do
            token.group.update!(active: false)
          end

          it { is_expected.not_to be_available }
        end
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
