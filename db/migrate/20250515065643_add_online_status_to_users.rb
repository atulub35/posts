class AddOnlineStatusToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :online_status, :boolean, default: false
    add_column :users, :last_seen_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
