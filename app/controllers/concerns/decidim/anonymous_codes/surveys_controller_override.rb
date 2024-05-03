# frozen_string_literal: true

module Decidim
  module AnonymousCodes
    module SurveysControllerOverride
      extend ActiveSupport::Concern

      included do
        before_action do
          next unless current_settings.allow_answers? && survey.open?
          next if visitor_already_answered?

          if token_groups.active.any?
            next if current_token&.available?

            if current_token.blank?
              flash.now[:alert] = I18n.t("decidim.anonymous_codes.invalid_code") if params.has_key?(:token)
            elsif current_token.used?
              flash.now[:alert] = I18n.t("decidim.anonymous_codes.used_code")
            elsif current_token.expired?
              flash.now[:alert] = I18n.t("decidim.anonymous_codes.expired_code")
            end
            render "decidim/anonymous_codes/surveys/code_required"
          end

          if token_groups.inactive.any? && current_user&.admin?
            flash.now[:alert] = I18n.t("decidim.anonymous_codes.inactive_group", path: decidim_admin_anonymous_codes.edit_code_group_path(token_groups.inactive.first)).html_safe
          end
        end

        after_action only: :answer do
          next unless current_token&.available?

          # find any answer for the current user and questionnaire that would be used as a resource to link the usage counter
          answer = Decidim::Forms::Answer.find_by(questionnaire: questionnaire, user: current_user, session_token: @form.context.session_token)
          current_token.answers << answer if answer.present?
        end

        private

        def token_groups
          @token_groups ||= Decidim::AnonymousCodes::Group.where(resource: survey)
        end

        def current_token
          @current_token ||= Decidim::AnonymousCodes::Token.where(group: token_groups.active).find_by("UPPER(token) = ?", token_param.to_s.upcase)
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
