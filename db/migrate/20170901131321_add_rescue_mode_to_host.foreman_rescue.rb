class AddRescueModeToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :rescue_mode, :boolean, default: false, index: true
  end
end
