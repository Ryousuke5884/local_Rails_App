class User < ApplicationRecord
  #dbには小文字で保存する
  before_save { email.downcase!}


  #:trueはオプションハッシュでメソッドの最後の引数としてハッシュを渡すときかっこ省略できる、validates(:name, presence: true)と同じ
  #maximumはハッシュではなく数値なので{}が必要
  validates :name, presence: true, length: { maximum: 50 }

  #メアドの正規表現、型通りかどうか
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },format: { with: VALID_EMAIL_REGEX },uniqueness: true

  #has_secure_passwordについては6.3を参照
  has_secure_password

  validates :password , presence:true,length:{minimum: 6}
end
