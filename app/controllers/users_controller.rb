class UsersController < ApplicationController

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


  #strongParametorを使ってユーザーが送信できる情報に制限をかける、admin属性などをいじられないようにするため
  private
   def user_params
    params.require(:user).permit(:name,:email,:password,:password_confirmation)
   end
end
