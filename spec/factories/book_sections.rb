FactoryBot.define do
  factory :book_section do
    content { "MyText" }
    metadata { "" }
    embedding { "" }
    book { nil }
  end
end
