class UsersController < ApplicationController
  #ログインを要求する
  before_action :logged_in_user,only:[:index,:edit,:update,:destroy]
  #正しいユーザーか確認する
  before_action :correct_user, only: [:edit, :update]
  #admin_userのprivateメソッドをつかって管理者かどうか確認してからdestroy実行
  before_action :admin_user,only: :destroy


  def index
    #@users変数に全ユーザーを入れて扱う
    #paginateが扱えるオブジェクトにするべくpaginate関数で変換する
    @users = User.paginate(page: params[:page])
  end



  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    #下の関数でStrongParamatorを使って制限した値でnewをする
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Sample App!"

      redirect_to user_url(@user)
    else
      render "new",status: :unprocessable_entity
    end 
  end

  #指定したユーザーが自分のプロフィールを編集
  def edit
    @user = User.find(params[:id])
  end


  #編集部分をアップデート
  def update
    @user = User.find(params[:id])
    #user_paramsで制限をかける
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit",status: :unprocessable_entity
    end
  end



  #adminがユーザーを削除するアクション
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end


  #strongParametorを使ってユーザーが送信できる情報に制限をかける、admin属性などをいじられないようにするため
  private
   def user_params
    params.require(:user).permit(:name,:email,:password,:password_confirmation)
   end

   #beforeフィルタ

   #ログイン済みユーザーか検証
   def logged_in_user
    unless logged_in?
      #sessionヘルパー内の手作り関数、ここで直前のurlを覚えておく
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url,status: :see_other
    end
   end

   # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  #管理者かどうか確認するadmin以外はrootに戻す
  def admin_user
    redirect_to(root_url,status: :see_other) unless current_user.admin?
  end

end
