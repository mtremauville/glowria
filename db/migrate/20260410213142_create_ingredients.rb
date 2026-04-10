class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.string :inci_name
      t.string :function
      t.text :concerns
      t.text :benefits
      t.timestamps
    end
  end
end
