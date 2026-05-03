class CreateBookSections < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'vector' # Đảm bảo extension đã bật
    create_table :book_sections do |t|
      t.text :content
      t.jsonb :metadata # Lưu số trang, chương...
      t.vector :embedding, limit: 768
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
    # Thêm chỉ mục để tìm kiếm vector nhanh hơn (HNSW hoặc IVFFlat)
    add_index :book_sections, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end
end
