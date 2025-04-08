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


  # 渡された文字列のハッシュ値を返す、8.2.6参照
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
