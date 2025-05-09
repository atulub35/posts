class AddConversationToMessages < ActiveRecord::Migration[7.0]
  def up
    # First add the column as nullable
    add_reference :messages, :conversation, foreign_key: true

    # Group messages by user_id and create conversations for each user
    Message.group(:user_id).pluck(:user_id).each do |user_id|
      # Create a conversation with a system user
      conversation = execute <<-SQL
        INSERT INTO conversations (created_at, updated_at) 
        VALUES (NOW(), NOW()) 
        RETURNING id;
      SQL
      conversation_id = conversation.first['id']

      # Add conversation participants
      execute <<-SQL
        INSERT INTO conversation_participants (conversation_id, user_id, created_at, updated_at)
        VALUES (#{conversation_id}, #{user_id}, NOW(), NOW());
      SQL

      # Update messages for this user
      execute <<-SQL
        UPDATE messages 
        SET conversation_id = #{conversation_id}
        WHERE user_id = #{user_id};
      SQL
    end

    # Keep the column nullable since AI messages won't have a conversation
    # change_column_null :messages, :conversation_id, false
  end

  def down
    remove_reference :messages, :conversation
  end
end
