class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :title
      t.text :text

      t.timestamps null: false
    end
  end
end
