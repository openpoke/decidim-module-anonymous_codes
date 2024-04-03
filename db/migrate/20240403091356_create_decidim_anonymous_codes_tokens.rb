# frozen_string_literal: true

class CreateDecidimAnonymousCodesTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_anonymous_codes_tokens do |t|
      t.string :token, null: false
      t.integer :usage_count, default: 0, null: false

      t.references :group, null: false, index: { name: "decidim_anonymous_codes_tokens_on_group" }
      t.references :resource, polymorphic: true, null: true, index: { name: "decidim_anonymous_codes_tokens_on_resource" }
      t.timestamps
    end
  end
end
