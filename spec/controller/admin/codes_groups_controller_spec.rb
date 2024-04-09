# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CodeGroupsController, type: :controller do
        routes { Decidim::AnonymousCodes::AdminEngine.routes }
        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:current_organization) { create(:organization) }

        before do
          request.env["decidim.current_organization"] = current_organization
          sign_in current_user
        end

        describe "GET #index" do
          it "assigns @groups and renders the index template" do
            group = Decidim::AnonymousCodes::Group.create(
              title: "Sample Group",
              expires_at: 1.day.from_now,
              active: true,
              max_reuses: 10,
              organization: current_organization
            )

            get :index
            expect(assigns(:groups)).to eq([group])
            expect(response).to render_template("index")
          end
        end

        describe "GET #new" do
          it "assigns a new form and renders the new template" do
            get :new
            expect(assigns(:form)).to be_a(CodeGroupForm)
            expect(response).to render_template("new")
          end
        end
      end
    end
  end
end
