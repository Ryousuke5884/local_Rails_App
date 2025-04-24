class ApplicationController < ActionController::Base
    #ログインメソッドはどこのコントローラからでもアクセスしたいので、親クラスのここでログインヘルパーをinclude
    include SessionsHelper

    #beforeフィルターでログインしているか確認も使いまわしたいので親クラスで定義
    private
        # ユーザーのログインを確認する
        def logged_in_user
            unless logged_in?
                store_location
                flash[:danger] = "Please log in."
                redirect_to login_url, status: :see_other
            end
        end
end
