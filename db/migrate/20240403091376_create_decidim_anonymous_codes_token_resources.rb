# frozen_string_literal: true

class CreateDecidimAnonymousCodesTokenResources < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_anonymous_codes_token_resources do |t|
      t.references :token, null: false, index: { name: "decidim_anonymous_codes_token_resources_on_token" }
      t.references :resource, polymorphic: true, null: false, index: { name: "decidim_anonymous_codes_token_resources_on_resource" }
      t.timestamps
    end
  end
end
