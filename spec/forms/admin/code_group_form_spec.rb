# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CodeGroupForm do
        subject { form }
        let(:current_organization) { create(:organization) }
        let(:current_user) { create :user, organization: current_organization }
        let(:form_params) do
          {
            title_en: "Sample Title",
            title_ca: "Títol de la mostra",
            title_es: "Titulo de ejemplo",
            expires_at: expires,
            active: active,
            max_reuses: max_reuses,
            num_tokens: num_tokens
          }
        end
        let(:active) { true }
        let(:expires) { 1.day.from_now }
        let(:max_reuses) { 10 }
        let(:num_tokens) { nil }
        let(:form) do
          CodeGroupForm.from_params(
            form_params
          ).with_context(
            current_organization: current_organization
          )
        end

        describe "validations" do
          it { is_expected.to be_valid }

          context "when max reuses is less than 1" do
            let(:max_reuses) { 0 }

            it "is invalid" do
              expect(subject).to be_invalid
              expect(form.errors[:max_reuses]).to include("must be greater than 0")
            end
          end

          context "when expires_at is in the past" do
            let(:active) { false }
            let(:expires) { 1.day.ago }

            it { is_expected.to be_valid }

            context "when active" do
              let(:active) { true }

              it "is invalid" do
                expect(subject).to be_invalid
                expect(form.errors[:expires_at].first).to include("must be after")
              end
            end

            context "and date is not present" do
              let(:expires) { "" }

              it { is_expected.to be_valid }
            end
          end

          context "when num_tokens" do
            let(:num_tokens) { 10 }

            it { is_expected.to be_valid }

            context "and num_tokens is zero" do
              let(:num_tokens) { 0 }

              it { is_expected.to be_invalid }
            end

            context "and num_tokens is less than zero" do
              let(:num_tokens) { -1 }

              it { is_expected.to be_invalid }
            end
          end
        end
      end
    end
  end
end
