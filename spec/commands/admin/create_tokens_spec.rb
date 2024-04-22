# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CreateTokens, type: :command do
        let(:form) { double("FormObject", invalid?: false, num_tokens: 10) }
        let(:code_group) { double("CodeGroup") }
        let(:command) { described_class.new(form, code_group) }

        describe "#call" do
          before do
            allow(CreateTokensJob).to receive(:perform_later)
            command.call
          end

          context "when the form is valid" do
            it "queues a background job to create tokens" do
              expect(CreateTokensJob).to have_received(:perform_later).with(code_group, 10)
            end

            it "broadcasts :ok" do
              expect(command).to broadcast(:ok)
            end
          end

          context "when the form is invalid" do
            let(:form) { double("FormObject", invalid?: true) }

            it "broadcasts :invalid" do
              expect(command).to broadcast(:invalid)
            end

            it "does not queue a background job" do
              expect(CreateTokensJob).not_to have_received(:perform_later)
              expect(CreateTokensJob).not_to have_received(:perform_later).with(code_group, 10)
            end
          end
        end
      end
    end
  end
end
