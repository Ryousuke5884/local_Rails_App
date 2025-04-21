class User < ApplicationRecord
  #attr_accessorを使うと、remember_tokenにアクセスするセッターとゲッターを生成してくれる・constなどで箱を作らないのはユーザーごとに違う値を入れるから、これならインスタンスごとにremember_tokenを分けられる 
  #remember_tokenは生成したトークンを入れるために一時的に使いまわしたいインスタンス変数、メモリ上のみ、DBにはremember_digestに変換してから入れたい
  attr_accessor :remember_token, :activation_token,:reset_token

  #dbには小文字で保存する
  before_save :downcase_email

  #新しいユーザーからUser.newで生成される直前に有効化に必要な情報を生成しておく、それをUserオブジェクト生成後に保存
  before_create :create_activation_digest


  #:trueはオプションハッシュでメソッドの最後の引数としてハッシュを渡すときかっこ省略できる、validates(:name, presence: true)と同じ
  #maximumはハッシュではなく数値なので{}が必要
  validates :name, presence: true, length: { maximum: 50 }

  #メアドの正規表現、型通りかどうか
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },format: { with: VALID_EMAIL_REGEX },uniqueness: true

  #has_secure_passwordについては6.3を参照
  has_secure_password

  #空を許しているのはユーザー更新時にパスワードが空でも通すため、新規登録の際のパスワードバリテーションはhas_secure_passwordで引っかかるから大丈夫
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


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


  #sendメソッドはRubyのメタプログラミングであまり難しくないが、11.3.1参照
  #attributeは:rememberや:activationなどどんなダイジェストを参照するか、tokenは比較対象でユーザーが送ってくるもの。
  # 渡されたトークンがダイジェストと一致したら true を返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    #digestとtokenを比較してboolを返す
    BCrypt::Password.new(digest).is_password?(token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest,nil)
  end


  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する,User.newの直前に呼ばれて代入される
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end


  #パスワード再設定用の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,User.digest(reset_token))
    update_attribute(:reset_sent_at,Time.zone.now)
  end

  #パスワード再設定用のメールを送信
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end


  # パスワード再設定の期限が切れている場合は true を返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end
    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
