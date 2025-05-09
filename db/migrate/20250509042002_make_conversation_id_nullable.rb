class MakeConversationIdNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :messages, :conversation_id, true
  end
end
