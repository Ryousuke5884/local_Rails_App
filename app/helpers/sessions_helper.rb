module SessionsHelper

  #すべてのコントローラーの親クラスのapplicationControllerでincludeしているのでどこからでもloginメソッドが使える
  def log_in(user)
    #こうすると自動でcookieに暗号化したuseridを保存してくれる
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if session[:user_id]
      #||=はA=A||B、Aがあるならそのまま、ないならBをAに代入とするときA||=Bと書ける
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  #ユーザーがログインしているかどうかboolを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    reset_session
    @current_user = nil # 安全のため
  end
end
