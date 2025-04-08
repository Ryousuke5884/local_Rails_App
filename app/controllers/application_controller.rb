class ApplicationController < ActionController::Base
    #ログインメソッドはどこのコントローラからでもアクセスしたいので、親クラスのここでログインヘルパーをinclude
    include SessionsHelper
end
