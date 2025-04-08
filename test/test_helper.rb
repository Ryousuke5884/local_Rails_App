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
end
