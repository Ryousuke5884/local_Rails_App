class StaticPagesController < ApplicationController
  def home
    if logged_in?
      #micropostをビルドしてフォームに入れておくオブジェクトを作る。フォームからこのオブジェクト編集してpostする
      @micropost = current_user.microposts.build

      #feedを取得しておく
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
    
  end
  def contact
    
  end
end
