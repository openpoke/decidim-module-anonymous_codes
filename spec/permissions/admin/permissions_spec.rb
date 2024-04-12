# frozen_string_literal: true

require "spec_helper"

module Decidim::AnonymousCodes::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action).permissions.allowed? }

    let(:organization) { create :organization }
    let(:user) { build :user, :admin, organization: organization }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    shared_examples "crud permissions" do
      describe "create" do
        let(:action) do
          { scope: :admin, action: :create, subject: action_subject }
        end

        it { is_expected.to be true }
      end

      describe "update" do
        let(:action) do
          { scope: :admin, action: :update, subject: action_subject }
        end

        it { is_expected.to be true }
      end

      describe "destroy" do
        let(:action) do
          { scope: :admin, action: :destroy, subject: action_subject }
        end

        it { is_expected.to be true }
      end

      context "when any other action" do
        let(:action) do
          { scope: :admin, action: :foo, subject: action_subject }
        end

        it_behaves_like "permission is not set"
      end
    end

    context "when editing codes_group" do
      let(:action_subject) { :anonymous_code_group }

      it_behaves_like "crud permissions"
    end

    context "when any other condition" do
      let(:action) do
        { scope: :public, action: :foo, subject: :foo }
      end

      it_behaves_like "permission is not set"
    end
  end
end
