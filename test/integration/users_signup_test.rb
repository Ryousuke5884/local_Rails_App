require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  #無効なユーザー登録を行った場合のテスト


  test "invalid signup information" do
    get signup_path

    #このassert_no_differenceと引数のUser.countは、失敗するはずの内容でuserをpostした前後でUserの数が変わらないことを確認している
    #User.countに""がついている理由は、中身を実行した後に呼ぶため、ちなみにアロー関数にすれば別に""付けなくて大丈夫
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
      email: "user@invalid",
      password: "foo",
      password_confirmation: "bar" } }
    end

    #送信に失敗したら、HTMLコード422で更新してかつusers/newに戻っている
    assert_response :unprocessable_entity
    assert_template "users/new"

    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
  end
  
  test "valid signup information" do
    #differenceでuser.countの数が１増えるのを確認

    assert_difference "User.count" , 1 do
      post users_path, params: { user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end

    follow_redirect!
    assert_template "users/show"
    assert_not flash.empty?
    assert is_logged_in?
  end

end


