# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CreateCodeGroup do
        let(:current_organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:form_params) do
          {
            title: "Sample Title",
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
            expect { command.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
