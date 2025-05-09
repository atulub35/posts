class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :users, through: :conversation_participants

  validate :users_count_valid, on: :update

  def other_participant(user)
    users.where.not(id: user.id).first
  end

  private

  def users_count_valid
    return unless users.size != 2
    errors.add(:users, "must be exactly 2")
  end
end 