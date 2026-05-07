class StaticPagesController < ApplicationController
  include ApplicationHelper
  def home
    # @pagy_books, @recommended_books = pagy(Book.recommended,
    #                                        items: Settings.digits.digit_14)
    @pagy_books, @recommended_books = pagy(
      Book.recommended
          .with_attached_image
          .includes(:author),
      items: Settings.digits.digit_10
    )
  end

  def help; end
end
