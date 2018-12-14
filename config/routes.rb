Rails.application.routes.draw do
  get 'about' => 'about'

  get 'policy/policy'
  get 'policy/termsofuse'

  get 'search/search'
  post 'search/search' => 'search#search'

  get 'manager/manager'
  get 'manager/genre'
  get 'manager/genre_reg' => 'manager'
  post 'manager/genre_del' => 'genre_del'
  get 'manager/channel' => 'channel'
  post 'manager/channel_del' => 'channel_del'
  get 'manager/user' => 'user'
  post 'manager/user_del' => 'user_del'
  get 'manager/program'
  post 'manager/program_del' => 'program_del'
  get 'manager/pro_analy' => 'pro_analy'
  get 'manager/user_analy' => 'user_analy'
  get 'manager/update_program_unix' => 'update_program_unix'
  get 'manager/timecheck' => 'timecheck'
  get 'manager/user_ranking' => 'user_ranking'

  get 'login/login'
  get 'login/twitter'
  get 'login/google' => 'google#callback_auth'
  get 'login/userview' => 'login#userview'
  get 'login/yokiview' => 'login#yokiview'

  get 'program/top'
  post 'program/registerform' => 'program#create'
  get '/program/registerform' => 'program#registerform'
  get '/program/registerform/:id' => 'program#registerform'

  post 'program/register' => 'program#create'
  get '/program/detail' => 'program#detail'
  get '/program/detail/:id' => 'program#detail'
  get '/program/:id/edit' => 'program#edit'
  post '/program/:id/update' => 'program#update'
  post '/program/:id/like' => 'program#like'
  get '/program/:id/like' => 'program#like'
  get '/program/:id/like_ajax' => 'program#like_ajax'
  get '/program/:id/del' => 'program#del'

  get '/program/search' => 'search#show'
  post '/program/search' => 'search#show'
  get '/program/search/sort1' => 'search#sort1'

  get 'top', to: 'program#top'

  get '/login', to: 'login#login'
  post '/login', to: 'login#login'

  post '/program/channelinfo' => 'program#channelinfo'
  get '/program/channelinfo' => 'program#channelinfo'
  post '/program/mychannel' => 'program#mychannel'
  get '/program/mychannel' => 'program#mychannel'

  root to: "program#top"

  get "/auth/twitter/callback" => "sessions#create"
  get 'logout' => 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get '/contact/form' => "contact#form"
  post '/contact/create' => "contact#create"
  get '/contact/thank' => "contact#thank"

  get '*anything' => 'errors#routing_error'
end
