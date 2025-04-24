class Micropost < ApplicationRecord
  belongs_to :user

  #ActiveStrageを使ってマイクロポストにimageを紐づける、oneAttachedなので一つのマイクロポストに就き一つの画像
  has_one_attached :image

  #default scopeを使ってmicropostを新しい順で取り出す、->はラムダ式でブロックを引数に取る、descは古い順ではなく新しい順で撮りたいときのオプション
  default_scope -> { order(created_at: :desc) }

  #ここでmicropostsに制限をかけていく
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                  message: "must be a valid image format" },
                                  size: { less_than: 5.megabytes,
                                  message: "should be less than 5MB" }
end
