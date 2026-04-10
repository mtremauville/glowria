class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.string :barcode
      t.string :category
      t.string :image_url
      t.string :shop_url
      t.text :description
      t.timestamps
    end
  end
end
