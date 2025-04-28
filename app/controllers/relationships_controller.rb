class RelationshipsController < ApplicationController
  before_action :logged_in_user


  def create
    #HotwireのTurbo無しでページごとリダイレクトするパターン14.2.4
    # user = User.find(params[:followed_id])
    # current_user.follow(user)
    # redirect_to user

    #HotwireのTurboを使ってfollowボタンのみ再レンダリングするパターン14.2.5
    #userはインスタンス変数にする必要がある、これは<アクション名>.turbo_stream.erbファイルでも@userにアクセスしたいから
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    #respond_toメソッドでは中二行の内どちらかが実行される。
    respond_to do |format|
      #こっちは下の行が失敗したとき通常のリダイレクトをする用
      format.html { redirect_to @user }
      #こっちが<アクション名>.turbo_stream.erbに対応するファイルを探して一部のみ更新する機能を持つ。<アクション名>.turbo_stream.erbファイルの中にフォロー数を1増やす部分とfollowボタンの更新部分が入ってる。
      format.turbo_stream
    end
  end


  def destroy
    #HotwireのTurbo無しでページごとリダイレクトするパターン14.2.4
    # user = Relationship.find(params[:id]).followed
    # current_user.unfollow(user)
    # redirect_to user, status: :see_other

    #HotwireのTurboを使ってfollowボタンのみ再レンダリングするパターン14.2.5
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
