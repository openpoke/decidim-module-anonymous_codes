# frozen_string_literal: true

require "spec_helper"

module Decidim::AnonymousCodes
  describe TokenSerializer do
    include Decidim::TranslationsHelper

    subject { described_class.new(token) }
    let(:group) { create(:anonymous_codes_group, expires_at: expires_at, active: active, max_reuses: max_reuses, resource: resource) }
    let(:resource) { create(:survey) }
    let(:active) { true }
    let(:expires_at) { nil }
    let(:max_reuses) { 1 }
    let(:token) { create(:anonymous_codes_token, group: group) }
    let(:serialized) { subject.serialize }
    let(:resource_url) do
      "#{Decidim::ResourceLocatorPresenter.new(resource).url}?token=#{token.token}"
    end

    it "returns a hash with the serialized data for the token" do
      expect(serialized).to include(token: token.token)
      expect(serialized).to include(group: translated_attribute(group.title))
      expect(serialized).to include(available: true)
      expect(serialized).to include(used: false)
      expect(serialized).to include(usage_count: 0)
      expect(serialized).to include(expired: false)
      expect(serialized).to include(expires_at: nil)
      expect(serialized).to include(created_at: I18n.l(token.created_at, format: :decidim_short))
      expect(serialized).to include(resource_type: resource.class.name)
      expect(serialized).to include(resource_id: resource.id)
      expect(serialized).to include(resource_url: resource_url)
    end

    context "when the group has an expiration date" do
      let(:expires_at) { 1.day.from_now }

      it "returns the expiration date" do
        expect(serialized).to include(available: true)
        expect(serialized).to include(expired: false)
        expect(serialized).to include(expires_at: I18n.l(expires_at, format: :decidim_short))
      end

      context "and expired" do
        let(:expires_at) { 1.day.ago }

        it "returns expired as true" do
          expect(serialized).to include(available: false)
          expect(serialized).to include(expired: true)
        end
      end
    end

    context "when used" do
      let(:token) { create(:anonymous_codes_token, :used, group: group) }

      it "returns used as true" do
        expect(serialized).to include(available: false)
        expect(serialized).to include(used: true)
        expect(serialized).to include(usage_count: 1)
      end
    end

    context "when no resource attached" do
      let(:group) { create(:anonymous_codes_group, resource: nil) }

      it "returns nil for resource_type, resource_id and resource_url" do
        expect(serialized).to include(resource_type: nil)
        expect(serialized).to include(resource_id: nil)
        expect(serialized).to include(resource_url: nil)
      end
    end
  end
end
