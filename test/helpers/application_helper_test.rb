require "test_helper"

class ApplicationHelperTest < ActionView::TestCase

  #full_titleというヘルパー関数が動くかのテスト
  test "full title helper"do
    assert_equal "Ruby on Rails Tutorial Sample App", full_title
    assert_equal "Help | Ruby on Rails Tutorial Sample App", full_title("Help")
  end

end