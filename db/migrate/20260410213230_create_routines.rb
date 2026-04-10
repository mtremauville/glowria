class CreateRoutines < ActiveRecord::Migration[8.1]
  def change
    create_table :routines do |t|
      t.references :user, null: false, foreign_key: true
      t.string :period
      t.string :name
      t.text :ai_summary
      t.datetime :generated_at
      t.timestamps
    end
  end
end
