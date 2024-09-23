class AddUserIdToPosts < ActiveRecord::Migration[7.0]
  def change
    add_reference :posts, :user, foreign_key: true

    # Assign a default user to existing posts (assuming there's a user with ID 1)
    Post.update_all(user_id: 1)
    
    change_column_null :posts, :user_id, false
  end
end
