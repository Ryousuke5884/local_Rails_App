require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid"do
    assert @micropost.valid?
  end

  test "user id should be present"do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end


  #マイクロポストのcontentが空文字や140文字以上じゃないか
  test "content should be present" do
    @micropost.content = " "
    assert_not @micropost.valid?
  end
  
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  #マイクロポストが時間昇順で取り出されているか(default scopeを使って昇順を決めて取り出しているか)
  test "order should be most recent first"do
    #マイクロポストの最新の一軒と取り出した最初の一件が同じかどうか、most_recentはfixtureで作ったマイクロポストで、Time.zone.nowをcreated_atに入れてる
    assert_equal microposts(:most_recent),Micropost.first
  end

end
