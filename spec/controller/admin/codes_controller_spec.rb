# frozen_string_literal: true

require "spec_helper"

module Decidim
  module AnonymousCodes
    module Admin
      describe CodesController, type: :controller do
        routes { Decidim::AnonymousCodes::AdminEngine.routes }

        let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
        let(:current_organization) { create(:organization) }
        let!(:group) { create(:anonymous_codes_group, expires_at: 1.day.from_now, active: true, max_reuses: 10, organization: current_organization) }
        let(:code_group) { create(:anonymous_codes_group, organization: current_organization) }

        before do
          request.env["decidim.current_organization"] = current_organization
          sign_in current_user, scope: :user
        end

        describe "GET #index" do
          let!(:token1) { create(:anonymous_codes_token, group: code_group, created_at: 2.days.ago) }
          let!(:token2) { create(:anonymous_codes_token, group: code_group, created_at: 1.day.ago) }

          it "enforces permission to view anonymous code tokens" do
            expect(controller).to receive(:enforce_permission_to).with(:view, :anonymous_code_token)
            get :index, params: { code_group_id: code_group.id }
          end

          it "assigns @tokens with paginated tokens ordered by creation date" do
            get :index, params: { code_group_id: code_group.id }

            expect(assigns(:tokens)).to contain_exactly(token2, token1)
          end

          it "renders the index template" do
            get :index, params: { code_group_id: code_group.id }
            expect(response).to render_template(:index)
          end
        end

        describe "GET #new" do
          it "enforces permission to create anonymous code tokens" do
            expect(controller).to receive(:enforce_permission_to).with(:create, :anonymous_code_token)
            get :new, params: { code_group_id: code_group.id }
          end

          it "assigns a new instance of TokensForm to @form" do
            get :new, params: { code_group_id: code_group.id }
            expect(assigns(:form)).to be_an_instance_of(TokensForm)
          end

          it "renders the new template" do
            get :new, params: { code_group_id: code_group.id }
            expect(response).to render_template(:new)
          end
        end

        describe "POST #create" do
          context "with valid parameters" do
            let(:valid_params) do
              {
                code_group_id: code_group.id,
                num_tokens: 5
              }
            end

            it "enqueues a job to create tokens and redirects to code group codes path" do
              expect(CreateTokensJob).to receive(:perform_later).with(code_group, valid_params[:num_tokens])

              post :create, params: valid_params

              expect(response).to redirect_to(code_group_codes_path(code_group))
              expect(flash[:notice]).to be_present
            end
          end

          context "with invalid parameters" do
            let(:invalid_params) do
              {
                code_group_id: code_group.id,
                num_tokens: 0
              }
            end

            it "does not enqueue a job and renders the new template with an alert message" do
              expect(CreateTokensJob).not_to receive(:perform_later)

              post :create, params: invalid_params

              expect(response).to render_template("new")
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "DELETE #destroy" do
          let(:token) { create(:anonymous_codes_token, group: code_group, created_at: 2.days.ago) }
          let!(:group) { create(:anonymous_codes_group, expires_at: 1.day.from_now, active: true, max_reuses: 10, organization: current_organization) }
          let(:code_group) { create(:anonymous_codes_group, organization: current_organization) }

          it "destroys the token" do
            delete :destroy, params: { code_group_id: code_group.id, id: token.id }
            expect(response).to redirect_to(code_group_codes_path)
            expect(flash[:notice]).to be_present
            expect { token.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
