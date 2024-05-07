# frozen_string_literal: true

class MigrateRescueSettingsCategoryToDsl < ActiveRecord::Migration[6.0]
  class MigrationSettings < ApplicationRecord
    self.table_name = :settings
  end

  def up
    MigrationSettings.where(category: 'Setting::Rescue').update_all(category: 'Setting') if column_exists?(
      :settings, :category
    )
  end
end
