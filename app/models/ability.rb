class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new # guest

    if user.admin?
      setup_admin_permissions
    elsif user.persisted?
      setup_member_permissions(user)
    else
      setup_guest_permissions
    end
  end

  private

  def setup_admin_permissions
    # Admin have full access to everything
    can :manage, :all
  end

  def setup_member_permissions user
    # Users can read books, authors, and their own profile
    can :read, [Book, Author]
    can :read, %i(favorites follows)
    can :read, [BorrowRequest, User], id: user.id

    # Users can update their own profile
    can :update, User, id: user.id

    # Users can perform actions on their own borrow requests
    can %i(cancel edit_request update_request), BorrowRequest, user_id: user.id

    # Users can perform actions on books & authors
    can :borrow, Book
    can %i(add_to_favorite remove_from_favorite write_a_review destroy_review),
        Book
    can %i(add_to_favorite remove_from_favorite), Author
  end

  def setup_guest_permissions
    can :read, [Book, Author]
    # Guests can read home, about, and search pages
    can :read, %i(home about search)
  end
end
