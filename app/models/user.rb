class User < ApplicationRecord
  #attr_accessorを使うと、remember_tokenにアクセスするセッターとゲッターを生成してくれる・constなどで箱を作らないのはユーザーごとに違う値を入れるから、これならインスタンスごとにremember_tokenを分けられる 
  #remember_tokenは生成したトークンを入れるために一時的に使いまわしたいインスタンス変数、メモリ上のみ、DBにはremember_digestに変換してから入れたい
  attr_accessor :remember_token

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


  #クラス名.関数目の書き方はクラスメソッド、普通のインスタンスメソッドと違ってインスタンスを生成しなくても、まとめたい処理を入れる。例えばAをハッシュ化してA´にして返すだけなどユーザー個人で異ならないただの処理
  # 渡された文字列のハッシュ値を返す、8.2.6参照
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  #ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #remember処理はuserインスタンスごとにトークンを生成する場所だからインスタンスを作るインスタンス関数でやる(sessionsコントローラのヘルパーから呼ばれる)
  #永続的セッションのためにユーザーをDBに記憶する
  def remember
    self.remember_token = User.new_token
    #update_attributeは指定したDBの属性を更新する今回はremember_digest属性に保存
    update_attribute(:remember_digest,User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end


  #渡されたトークンがダイジェストと一致したらtrue
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest,nil)
  end
end
