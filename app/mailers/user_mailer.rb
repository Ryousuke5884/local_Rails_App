class UserMailer < ApplicationMailer
  default from: "ryousuke1213.gas@gmail.com"
  include Rails.application.routes.url_helpers

  #@user変数からメアドを抽出して送信先にする
  # def account_activation(user)
  #   @user = user
  #   mail to:user.email,subject:"Account activation"
  # end

  def account_activation(user)
    @user = user
    @activation_url = edit_account_activation_url(user.activation_token, email: user.email)
    mail to: user.email, subject: "Account activation"
  end
  
  def password_reset(user)
    @user = user

    mail to:user.email,subject: "Password reset"
  end
end
