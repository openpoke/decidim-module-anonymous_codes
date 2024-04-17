# frozen_string_literal: true

require "spec_helper"

module Decidim::AnonymousCodes::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create :organization }
    let(:user) { build :user, :admin, organization: organization }
    let(:context) do
      {}
    end
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    shared_examples "group crud permissions" do
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

        it_behaves_like "permission is not set"

        context "when destroyable" do
          let(:context) do
            { code_group: code_group }
          end

          let(:code_group) { create :anonymous_codes_group }

          it { is_expected.to be true }
        end

        context "when not destroyable" do
          let(:context) do
            { code_group: code_group }
          end

          let(:code_group) { create :anonymous_codes_group, :with_used_tokens }

          it { is_expected.to be false }
        end
      end

      context "when any other action" do
        let(:action) do
          { scope: :admin, action: :foo, subject: action_subject }
        end

        it_behaves_like "permission is not set"
      end
    end

    shared_examples "tokens crud permissions" do
      describe "view" do
        let(:action) do
          { scope: :admin, action: :view, subject: action_subject }
        end

        it { is_expected.to be true }
      end

      describe "create" do
        let(:action) do
          { scope: :admin, action: :create, subject: action_subject }
        end

        it { is_expected.to be true }
      end

      describe "destroy" do
        let(:action) do
          { scope: :admin, action: :destroy, subject: action_subject }
        end

        it_behaves_like "permission is not set"

        context "when any other action" do
          let(:action) do
            { scope: :admin, action: :foo, subject: action_subject }
          end

          it_behaves_like "permission is not set"
        end

        context "when token" do
          let(:context) do
            { token: token }
          end

          let(:token) { create :anonymous_codes_token }

          it { is_expected.to be true }
        end

        context "when used token" do
          let(:context) do
            { token: token }
          end

          let(:token) { create :anonymous_codes_token, :used }

          it { is_expected.to be false }
        end
      end
    end

    context "when editing codes_group" do
      let(:action_subject) { :anonymous_code_group }

      it_behaves_like "group crud permissions"
    end

    context "when editing tokens" do
      let(:action_subject) { :anonymous_code_token }

      it_behaves_like "tokens crud permissions"
    end

    context "when any other condition" do
      let(:action) do
        { scope: :public, action: :foo, subject: :foo }
      end

      it_behaves_like "permission is not set"
    end
  end
end
