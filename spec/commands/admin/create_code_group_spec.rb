# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CreateCodeGroup do
        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:form_params) do
          {
            title_en: "Sample Title",
            title_ca: "Títol de la mostra",
            title_es: "Titulo de ejemplo",
            expires_at: 1.day.from_now,
            active: true,
            max_reuses: 10,
            num_tokens: num_tokens
          }
        end
        let(:num_tokens) { nil }
        let(:form) do
          CodeGroupForm.from_params(
            form_params
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is invalid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create questionnaire answers" do
            expect do
              command.call
            end.not_to change(Group, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            perform_enqueued_jobs do
              expect { command.call }.to change(Group, :count).by(1).and broadcast(:ok)
              expect(Token.count).to eq(0)
            end
          end

          context "and num_tokens is specified" do
            let(:num_tokens) { 10 }

            it "broadcasts ok" do
              perform_enqueued_jobs do
                expect { command.call }.to change(Token, :count).by(10).and broadcast(:ok)
                expect(Group.count).to eq(1)
              end
            end
          end
        end
      end
    end
  end
end
