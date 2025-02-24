class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
  										length: {maximum: 140}
  validate  :picture_size
  # 単数系にすると自分でカスタムしたバリデーションを使用できる
  
  
  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "1MB以下の画像を選択してください")
      end
    end
end
