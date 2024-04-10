# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe UpdateCodeGroup do
        let(:current_organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:form_params) do
          {
            title_en: "Sample Code Group",
            title_ca: "Grup de codis de mostra",
            title_es: "Muestra de Códigos de Grupo",
            expires_at: 10.days.from_now,
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
        let(:code_group) do
          create(:anonymous_codes_group, expires_at: 5.days.from_now, active: true, max_reuses: 5, organization: current_organization)
        end
        let(:command) { described_class.new(form, code_group) }

        describe "#call" do
          context "when the form is valid" do
            it "updates the code group" do
              command.call
              expect(translated(code_group.title)).to eq("Sample Code Group")
            end

            it "broadcasts :ok with the updated code group" do
              expect(command).to receive(:broadcast).with(:ok, code_group)
              command.call
            end
          end

          context "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "does not update the code group" do
              expect(Decidim.traceability).not_to receive(:update!)
              command.call
            end

            it "broadcasts :invalid" do
              expect(command).to receive(:broadcast).with(:invalid)
              command.call
            end
          end
        end
      end
    end
  end
end
