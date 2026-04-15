class BookSection < ApplicationRecord
  belongs_to :book
  
  # Dòng này để dùng cho pgvector sau này
  has_neighbors :embedding
end
