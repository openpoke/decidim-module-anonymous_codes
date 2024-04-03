# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AnonymousCodes do
    subject { described_class }
    let(:token_length) { 10 }
    let(:token_style) { "alphanumeric" }

    before do
      allow(AnonymousCodes).to receive(:default_token_length).and_return(token_length)
      allow(AnonymousCodes).to receive(:token_style).and_return(token_style)
    end

    it "has a token generator" do
      expect(subject.token_generator.size).to eq(10)
      expect(subject.token_generator).to match(/\A\w+\z/)
    end

    context "when configuring the token length" do
      let(:token_length) { 5 }

      it "has a token generator" do
        expect(subject.token_generator.size).to eq(5)
      end
    end

    context "when configuring the token style" do
      let(:token_style) { "numeric" }

      it "has a token generator" do
        expect(subject.token_generator.size).to eq(10)
        expect(subject.token_generator).to match(/\A\d+\z/)
      end
    end
  end
end
