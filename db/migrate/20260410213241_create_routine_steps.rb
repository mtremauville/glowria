class CreateRoutineSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :routine_steps do |t|
      t.references :routine, null: false, foreign_key: true
      t.references :user_product, null: false, foreign_key: true
      t.integer :order
      t.string :instruction
      t.timestamps
    end
  end
end
