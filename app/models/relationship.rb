class Relationship < ApplicationRecord
  #こっちもmicropostモデルと違って名前が違うから手動で指定してる
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  #このvalidatesのpresenceを指定すると、空で保存ができなくなる→follower_idとfollowed_idは必ず値が入ることを保証する
  validates :follower_id, presence: true
  validates :followed_id, presence: true

end
