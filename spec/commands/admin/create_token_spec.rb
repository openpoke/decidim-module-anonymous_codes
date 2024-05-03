# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CreateToken, type: :command do
        let(:form) { double("FormObject", invalid?: invalid, token: "1SFDRG5SA") }
        let(:code_group) { create(:anonymous_codes_group) }
        let(:command) { described_class.new(form, code_group) }
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new token" do
            expect { command.call }.to change(Token, :count).by(1)
          end
        end
      end
    end
  end
end
