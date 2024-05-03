# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe TokensForm, type: :form do
        let(:form) { described_class.new }

        it "is valid with valid attributes" do
          form.token = "5ACVBHRTY8WETRD5"
          expect(form).to be_valid
        end

        it "is invalid without num_tokens" do
          form.token = nil
          expect(form).to be_invalid
          expect(form.errors[:token]).to include("can't be blank")
        end

        it "is invalid with token not being upercase" do
          form.token = "abc"
          expect(form).to be_valid
          expect(form.token).to eq("ABC")
        end

        it "is invalid with token with special characters" do
          form.token = "#@"
          expect(form).to be_invalid
          expect(form.errors[:token]).to include("must be all uppercase and contain only letters and/or numbers")
        end
      end
    end
  end
end
