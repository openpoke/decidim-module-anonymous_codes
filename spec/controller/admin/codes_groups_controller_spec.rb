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
          sign_in current_user, scope: :user
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

        describe "POST #create" do
          it "creates a new code group" do
            expect do
              post :create, params: { title: "New Group", expires_at: 1.day.from_now, active: true, max_reuses: 10 }
            end.to change(Decidim::AnonymousCodes::Group, :count).by(1)
            expect(response).to redirect_to(code_groups_path)
            expect(flash[:notice]).to eq(I18n.t("code_groups.create.success", scope: "decidim.anonymous_codes.admin"))
          end
        end

        context "when updating a group" do
          let(:current_organization) { create(:organization) }
          let(:group) do
            Decidim::AnonymousCodes::Group.create(
              title: "Sample Group",
              expires_at: 1.day.from_now,
              active: true,
              max_reuses: 10,
              organization: current_organization
            )
          end

          it "assigns the requested group to @group and renders the edit template" do
            get :edit, params: { id: group.id }
            expect(assigns(:code_group)).to eq(group)
            expect(response).to render_template("edit")
          end

          it "updates the group" do
            put :update, params: { id: group.id, title: "Updated Group" }
            group.reload
            expect(group.title).to eq("Updated Group")
            expect(response).to redirect_to(code_groups_path)
            expect(flash[:notice]).to eq(I18n.t("code_groups.update.success", scope: "decidim.anonymous_codes.admin"))
          end
        end
      end
    end
  end
end
