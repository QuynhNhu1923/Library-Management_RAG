FactoryBot.define do
  factory :book_section do
    book { nil }
    content { "MyText" }
    metadata { "" }
    embedding { "" }
  end
end
