Rails.application.routes.draw do

  get "/signup" , to: "users#new"
  
  root "static_pages#home"

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/login",to: "sessions#new"
  post "/login",to:"sessions#create"
  delete "/logout",to:"sessions#destroy"

  #ここではただusersに対しRESTなルーティングをするだけでなくmembeerを使って特定のidに対するルーティングを追加している、:usersはブロックを受け取れるのでブロック記法ができる
  resources :users do
    #memberを使うと個々のユーザーに対するルーティングができる。idを含むURLが作成される
    member do
      #それぞれのidに対しgetでfollowingとfollowersを作成、/users/:id/followingのようになる。
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  #Homeやプロフィールで表示するからnew,editは不要
  resources :microposts,only:[:create,:destroy]

  #フォロー、アンフォローのルーティング、ビューは作らずリクエストだけ受け取る
  resources :relationships, only: [:create, :destroy]

  #無効なマイクロポストを送信した後にブラウザ画面再読み込みをした際にNo rute matches[GET] "/microposts"が起こるのを避けるため
  get '/microposts', to: 'static_pages#home'

  
end
