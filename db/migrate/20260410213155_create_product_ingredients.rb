class CreateProductIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :product_ingredients do |t|
      t.references :product, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.integer :position
      t.timestamps
    end
  end
end
