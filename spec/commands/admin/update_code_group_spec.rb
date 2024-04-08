# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe UpdateCodeGroup do
        let(:current_organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:code_group) do
          Decidim::AnonymousCodes::Group.create(
            title: "Sample Code Group",
            expires_at: 10.days.from_now,
            active: true,
            max_reuses: 10,
            organization: current_organization
          )
        end
        let(:form) do
          CodeGroupForm.new(
            title: "New Title",
            expires_at: code_group.expires_at,
            active: code_group.active,
            max_reuses: code_group.max_reuses
          )
        end

        subject { described_class.new(form, code_group) }

        describe "#call" do
          context "when the form is valid" do
            it "updates the code group" do
              expect(Decidim.traceability).to receive(:update!).with(
                code_group,
                current_user,
                title: form.title,
                expires_at: form.expires_at,
                active: form.active,
                max_reuses: form.max_reuses
              )

              subject.call
            end

            it "broadcasts :ok with the updated code group" do
              expect(subject).to receive(:broadcast).with(:ok, code_group)
              subject.call
            end
          end

          context "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "does not update the code group" do
              expect(Decidim.traceability).not_to receive(:update!)
              subject.call
            end

            it "broadcasts :invalid" do
              expect(subject).to receive(:broadcast).with(:invalid)
              subject.call
            end
          end
        end
      end
    end
  end
end
