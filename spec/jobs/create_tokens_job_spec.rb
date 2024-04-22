# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    describe CreateTokensJob do
      subject { described_class.perform_now(code_group, num_tokens) }

      let(:organization) { create(:organization) }
      let(:code_group) { create :anonymous_codes_group }
      let(:num_tokens) { 2 }
      let(:token1) { "TOKEN1" }
      let(:token2) { "TOKEN2" }
      let(:token3) { "TOKEN3" }

      before do
        allow(Decidim::AnonymousCodes).to receive(:token_generator).and_return(token1, token2, token3)
      end

      it "generates 2 tokens" do
        expect { subject }.to change(Token, :count).by(2)
        expect(Token.all.pluck(:token)).to match_array([token1, token2])
      end

      context "when token is repeated" do
        let!(:existing_token) { create(:anonymous_codes_token, token: token2, group: code_group) }

        it "skips the repeated" do
          expect { subject }.to change(Token, :count).by(2)
          expect(Token.all.pluck(:token)).to match_array([token1, token2, token3])
        end
      end
    end
  end
end
