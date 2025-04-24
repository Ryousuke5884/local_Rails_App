require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @micropost = microposts(:orange)
  end

  #未ログイン時にポスとしても増えずにログインページへ行くか
  test "should redirect create when not logged in"do
    assert_no_difference "Micropost.count"do
      post microposts_path,params:{micropost: {content:"Lorem ipsum"}}
    end
    assert_redirected_to login_url
  end

  #未ログイン時にdestroyしても消えないか
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  #自分以外のマイクロポストを削除した場合
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference "Micropost.count" do
      delete micropost_path(micropost)
    end

    assert_response :see_other
    assert_redirected_to root_url
  end

end
