class Relationship < ApplicationRecord
	# IDとIDの関連付け
	# メソッドを定義するメソッド
	# belongs_to :user => user_id == @user.id
	# 								 => follwer_id == @user.id
	# 								 => follwed_id == @user.id
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
