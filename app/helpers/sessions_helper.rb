module SessionsHelper

  #すべてのコントローラーの親クラスのapplicationControllerでincludeしているのでどこからでもloginメソッドが使える
  def log_in(user)
    #こうすると自動でcookieに暗号化したuseridを保存してくれる
    session[:user_id] = user.id
    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  #永続セッションのためにユーザーをdbに記憶する
  def remember(user)
    #userモデルクラスのremmeberを呼ぶ
    user.remember

    #cookieにユーザーidとremember_digestを保存するユーザーidはencryptedメソッドで暗号化してから保存、(DBには上のuser.rememberでモデルが保存してる)
    #permanentは永続cookie(20年)を指定するもの
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end


  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    #ここ=で代入しているのは、(ユーザーIDにユーザーIDを代入した結果)存在すれば、という条件式
    if(user_id = session[:user_id])
      #||=はA=A||B、Aがあるならそのまま、ないならBをAに代入とするときA||=Bと書ける
      #@current_user ||=User.find_by(id: user_id)

      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end

    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end


  # 渡されたユーザーがカレントユーザーであれば true を返す
  def current_user?(user)
    user && user == current_user
  end


  #ユーザーがログインしているかどうかboolを返す
  def logged_in?
    !current_user.nil?
  end


  # 永続的セッションを破棄する(DB側はuser.forgetでモデル側から処理)
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end





  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil # 安全のため
  end


  # アクセスしようとした URL を保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
