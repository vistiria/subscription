class CreateContributions < ActiveRecord::Migration[5.1]
  def change
    create_table :contributions do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
