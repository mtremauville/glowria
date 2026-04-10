class CreateUserProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :user_products do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :usage_slot
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
