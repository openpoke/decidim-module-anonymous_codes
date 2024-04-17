# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe TokensForm, type: :form do
        let(:form) { described_class.new }

        it "is valid with valid attributes" do
          form.num_tokens = 5
          expect(form).to be_valid
        end

        it "is invalid without num_tokens" do
          form.num_tokens = nil
          expect(form).to be_invalid
          expect(form.errors[:num_tokens]).to include("can't be blank")
        end

        it "is invalid with num_tokens not being an integer" do
          form.num_tokens = "abc"
          expect(form).to be_invalid
          expect(form.errors[:num_tokens]).to include("must be greater than 0")
        end

        it "is invalid with num_tokens less than or equal to 0" do
          form.num_tokens = 0
          expect(form).to be_invalid
          expect(form.errors[:num_tokens]).to include("must be greater than 0")
        end
      end
    end
  end
end
