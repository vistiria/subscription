class AddPendingToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :pending, :boolean, null: false, default: false
  end
end
