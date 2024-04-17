# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CodesController, type: :controller do
        routes { Decidim::AnonymousCodes::AdminEngine.routes }
        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:current_organization) { create(:organization) }
        let(:component) { survey.component }
        let!(:survey) { create(:survey) }
        let!(:existing_group) { create(:anonymous_codes_group, title: { en: "Existing group" }, organization: organization, resource: survey) }
        let!(:existing_empty_group) { create(:anonymous_codes_group, title: { en: "Existing empty group" }, organization: organization, resource: survey) }
        let!(:anonymous_codes_token1) { create(:anonymous_codes_token, group: existing_group) }
        let!(:anonymous_codes_token2) { create(:anonymous_codes_token, :used, group: existing_group) }

        before do
          request.env["decidim.current_organization"] = current_organization
          sign_in current_user, scope: :user
        end
      end
    end
  end
end
