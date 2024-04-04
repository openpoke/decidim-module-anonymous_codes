# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module SurveysControllerOverride
      extend ActiveSupport::Concern

      included do
        before_action do
          unless token_groups.any? && current_token.present?
            flash.now[:alert] = I18n.t("decidim.anonymous_codes.invalid_code") if params.has_key?(:token)
            render "decidim/anonymous_codes/surveys/code_required"
          end
        end

        private

        def token_groups
          @token_groups ||= Decidim::AnonymousCodes::Group.where(resource: survey)
        end

        def current_token
          @current_token ||= Decidim::AnonymousCodes::Token.where(group: token_groups).find_by(token: token_param)
        end

        def token_param
          @token_param ||= begin
            session[:anonymous_codes_token] = params[:token] if params.has_key?(:token)
            session[:anonymous_codes_token]
          end
        end
      end
    end
  end
end
