class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration,only:[:edit,:update]

  
  def new
  end

  def create
    #パスワードリセットリクエストのparamsからメアドを探す、:password_resetはnewビューの:scopeで定義してる
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    
    #再登録するアカウントのメアドが無かったら
    else
      flash.now[:danger] = "Email address not found"
      render "new" , status: :unprocessable_entity
    end
  end

  #ユーザーに送られたリセットリンクリクエストに対するビューを書く
  def edit  
  end

  #ユーザーがメアドに来たリンクを踏んでフォームを埋めた後のアップデート
  def update
    #パスワードが空文字だった時
    if params[:user][:password].empty?
      @user.errors.add(:password,"can not be empty")
      render "edit",status: :unprocessable_entity
    
    #パスワード編集成功時
    elsif @user.update(user_params)
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user

    #無効なパスワードだった時
    else
      render "edit",status: :unprocessable_entity
    end
  end



  private
    
    def user_params
      params.require(:user).permit(:password,:password_confirmation)
    end


    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      #authenticated?などのメソッドはDBに問い合わせが発生するのでmodelで定義する
      unless (@user && @user.activated? &&@user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #トークンが有効期限切れか調べる
    def check_expiration
      #password_reset_expired?関数はDBアクセスがあるのでモデルで定義
      if @user.password_reset_expired?

        flash[:denger] = "Password resent has expired."
        redirect_to new_password_reset_url
      end
    end
end
