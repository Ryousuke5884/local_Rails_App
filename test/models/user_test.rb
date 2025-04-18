require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    #テストなので保存しないnewメソッド、createメソッドやsaveはしない
    @user = User.new(name: "Example User", email: "user@example.com",password: "foobar", password_confirmation: "foobar")
  end

  #有効性をチェックする、正しい型のメアドか、空欄じゃないかなど
  test "should be valid" do
    assert @user.valid?
  end

  #空白じゃないかテスト、nameに空白をセットし失敗することを確認
  test "name shold be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email=" "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a"*51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  #メアドが正しいフォーマットかどうか
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

    valid_addresses.each do |valid_addresses|
      @user.email = valid_addresses
      #第二引数はエラーメッセージ
      assert @user.valid?, "#{valid_addresses.inspect} should be valid"
      
    end    
  end

  #正しくないメアドをはじくかどうか
  test "email validation should refect inbvalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |invalid_addresses|
      @user.email = invalid_addresses
      assert_not @user.valid?, "#{invalid_addresses.inspect} should be invalid"

    end
  end



  #一意性のテスト※一意性のテストだけはnewでメモリ上でやるだけでなくdbにsaveなどで登録する必要あり
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    #saveする必要あり
    @user.save

    assert_not duplicate_user.valid?
  end

  #メアドがセーブ時に小文字かされているか
  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end



  #パスワードの最小文字数のテスト
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " *6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" *5
    assert_not @user.valid?
  end


  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
end
