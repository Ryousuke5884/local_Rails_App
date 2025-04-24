class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create,:destroy]
  before_action :correct_user, only: :destroy


  def create
    #micropost_paramsはprivate関数、buildしてcreateするmicropostの箱だけ作っておく、内容はpostアクションの中身を入れる
    @micropost = current_user.microposts.build(micropost_params)

    #マイクロポストオブジェクトに画像をくっつけられるようにする、ActiveStrageAPIのattachメソッドを使う
    @micropost.image.attach(params[:micropost][:image])

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render "static_pages/home",status: :unprocessable_entity
    end

    
  end

  def destroy
    @micropost.destroy
    flash[:success]  ="Micropost deleted"


    #referrerはユーザーの直前のURL、nilになることもあるから確認してからredirect、request.referrerで直前のurl文
    if request.referrer.nil?
      redirect_to root_url,status: :see_other
    else
      redirect_to request.referrer,status: :see_other
    end
  end

  private 
    def micropost_params
      #strongPramatorでcontent属性のみ変更を許す
      params.require(:micropost).permit(:content)
    end
    
    #正しいユーザーか
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end


end
