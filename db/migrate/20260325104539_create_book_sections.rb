class CreateBookSections < ActiveRecord::Migration[7.0]
  def change
    create_table :book_sections do |t|
      t.references :book, null: false, foreign_key: true
      t.text :content
      t.json :metadata
      t.vector :embedding, limit: 1536

      t.timestamps
    end
  end
end
