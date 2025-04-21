require "test_helper"

# 基底クラス：各テストクラス共通で使う初期化処理（メール送信履歴のリセット）を定義
class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

# パスワードリセットのリクエストフォームに関するテスト
class ForgotPasswordFormTest < PasswordResets
  # パスワードリセットページにアクセスでき、正しいフォームが表示されるか
  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  # 無効なメールアドレス（空）でリクエストを送ったとき、正しく処理されるか
  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

# 有効なメールアドレスでパスワードリセットをリクエストする処理を共通化するクラス
class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:michael)  # fixtures からユーザーを取得
    post password_resets_path, params: { password_reset: { email: @user.email } } # パスワードリセットをリクエスト
    @reset_user = assigns(:user)  # コントローラ内で代入された @user を取得
  end
end

# edit アクションに関するテスト（リセット用リンクを開くときの挙動）
class PasswordFormTest < PasswordResetForm
  # 正常なメールアドレスでリクエストが送られると、トークンが更新され、メールが送られ、リダイレクトされる
  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  # 不正なメールアドレスで edit アクションにアクセスしたとき、リダイレクトされる
  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  # アカウントが未アクティブのユーザーの場合、リセットページにアクセスできない
  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_redirected_to root_url
  end

  # 正しいメールアドレスだけどトークンが間違っている場合、リダイレクトされる
  test "reset with right email but wrong token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  # 正しいメールアドレスとトークンでアクセスした場合、正しいビューが表示され、hiddenフィールドにemailがある
  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

# パスワード更新処理（update アクション）のテスト
class PasswordUpdateTest < PasswordResetForm
  # パスワードと確認用パスワードが一致しない場合、エラーメッセージが表示される
  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token), params: { email: @reset_user.email, user: { password: "foobaz", password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  # パスワードが空欄の場合、エラーメッセージが表示される
  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token), params: { email: @reset_user.email, user: { password: "", password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  # 正しいパスワードと確認が入力された場合、ログインし、リダイレクトされる
  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token), params: { email: @reset_user.email, user: { password: "foobaz", password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end
