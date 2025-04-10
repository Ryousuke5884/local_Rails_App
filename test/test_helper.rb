ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

#Rails のテスト環境を設定するためのファイル

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...


  # テストユーザーがログイン中の場合に true を返す
  #isを付けたのはtestじゃないコントローラーのヘルパーと同じ名前にならないように
  def is_logged_in?
    !session[:user_id].nil?
  end

  #テストユーザーでログインする単体テスト側のloginasメソッド
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

#統合テスト側でもloginasを使えるようにする
class ActionDispatch::IntegrationTest

  #統合テストではセッションを直接呼べないのでloginにpostする
  def log_in_as(user,password:"password",remember_me:"1")
    post login_path,params:{session:{email:user.email,password:password,remember_me:remember_me}}
  end
end
