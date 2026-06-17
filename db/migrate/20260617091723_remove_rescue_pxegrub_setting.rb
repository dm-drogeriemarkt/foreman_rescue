# frozen_string_literal: true

class RemoveRescuePxegrubSetting < ActiveRecord::Migration[7.0]
  class MigrationSettings < ApplicationRecord
    self.table_name = :settings
  end

  def up
    MigrationSettings.where(name: 'rescue_pxegrub_tftp_template').delete_all
  end

  def down
    # no-op: the setting is re-created by plugin registration on boot if re-added
  end
end
