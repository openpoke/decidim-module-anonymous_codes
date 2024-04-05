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

      it { is_expected.not_to be_used }

      it "has an empty counter cache" do
        expect(token.usage_count).to eq(0)
      end

      context "when adding an answer" do
        let(:resource) { create(:answer, questionnaire: token.group.resource.questionnaire) }

        it "can be associated" do
          expect { token.answers << resource }.to change(token.token_resources, :count).by(1)
        end

        context "and the answer associated does not belong to the parent questionnaire" do
          let(:resource) { create(:answer) }

          it "cannot be associated" do
            expect { token.answers << resource }.to raise_error(ActiveRecord::RecordInvalid)
          end

          context "when different resource type" do
            let(:resource) { create(:questionnaire) }

            it "cannot be associated" do
              expect { create(:anonymous_codes_token_resource, token: token, resource: resource) }.to raise_error(ActiveRecord::RecordInvalid)
            end
          end
        end

        context "and max uses have been reached" do
          before do
            token.answers << resource
          end

          it "cannot be associated" do
            expect { token.answers << resource }.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end

      context "when resource exists" do
        let!(:token) { create(:anonymous_codes_token, :used) }

        it { is_expected.to be_used }

        it "has a counter cache" do
          expect(token.usage_count).to eq(1)
        end

        it "lowers the counter on removing the resource" do
          expect(TokenResource.count).to eq(1)
          expect { token.update!(token_resources: []) }.to change(token, :usage_count).by(-1)
          expect(TokenResource.count).to eq(0)
        end

        context "when max_reuses is 2" do
          before do
            token.group.update!(max_reuses: 2)
          end

          it { is_expected.not_to be_used }
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
