# frozen_string_literal: true

class AddRescueModeToHost < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :rescue_mode, :boolean, default: false, index: true
  end
end
