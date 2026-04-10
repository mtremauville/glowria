class CreateConflictRules < ActiveRecord::Migration[8.1]
  def change
    create_table :conflict_rules do |t|
      t.references :ingredient_a, null: false, foreign_key: { to_table: :ingredients }
      t.references :ingredient_b, null: false, foreign_key: { to_table: :ingredients }
      t.string :severity
      t.string :message
      t.string :recommendation
      t.timestamps
    end
  end
end
