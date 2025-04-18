class SessionsController < ApplicationController
  def new
  end

  #ログイン実行処理、こいつらにビューは必要ない
  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    #ログイン認証
    if @user && @user.authenticate(params[:session][:password])

      if @user.activated?
        #sessionヘルパーで保存しといたforwading_urlキーにアクセスして取得
        forwarding_url = session[:forwarding_url]
        #reset_sessionはRailsが自動で作るメソッド、log_inメソッドは親のapplication_controllerで私が定義したもの、userは引数の()省略
        reset_session

        #paramsのrememberチェックボックスがtrueなら1が入る 1ならログインを記憶
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        log_in @user
        redirect_to forwarding_url || @user

      else
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      #flash.nowはその後リクエストが発生した際に消えるもの。リロードなしで再レンダリングの場合flashを消せて便利
      flash.now[:danger] = 'Invalid email/password combination'
      render "new",status: :unprocessable_entity
    end    
  end

  #ログアウト処理、ヘルパーにあるlog_out関数を呼ぶ
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
