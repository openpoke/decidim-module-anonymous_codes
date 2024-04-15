# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CodeGroupForm do
        let(:current_organization) { create(:organization) }
        let(:current_user) { create :user, organization: current_organization }
        let(:form_params) do
          {
            title_en: "Sample Title",
            title_ca: "Títol de la mostra",
            title_es: "Titulo de ejemplo",
            expires_at: 1.day.from_now,
            active: true,
            max_reuses: 10
          }
        end
        let(:form) do
          CodeGroupForm.from_params(
            form_params
          ).with_context(
            current_organization: current_organization
          )
        end

        describe "validations" do
          context "when all attributes are valid" do
            it "is valid" do
              expect(form).to be_valid
            end
          end

          context "when max reuses is less than 1" do
            let(:form_params) do
              {
                title_en: "Sample Title",
                title_ca: "Títol de la mostra",
                title_es: "Titulo de ejemplo",
                expires_at: 1.day.from_now,
                active: true,
                max_reuses: 0
              }
            end

            it "is invalid" do
              expect(form).not_to be_valid
              expect(form.errors[:max_reuses]).to include("must be greater than 0")
            end
          end

          context "when expires_at is in the past" do
            let(:form_params) do
              {
                title_en: "Sample Title",
                expires_at: expires,
                active: active,
                max_reuses: 10
              }
            end
            let(:active) { false }
            let(:expires) { 1.day.ago }

            it "is valid" do
              expect(form).to be_valid
            end

            context "when active" do
              let(:active) { true }

              it "is invalid" do
                expect(form).to be_invalid
                expect(form.errors[:expires_at].first).to include("must be after")
              end
            end

            context "and date is not present" do
              let(:expires) { "" }

              it "is valid" do
                expect(form).to be_valid
              end
            end
          end
        end
      end
    end
  end
end
