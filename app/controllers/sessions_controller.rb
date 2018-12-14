class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])

# request.env['omniauth.auth']に、OmniAuthによってHashのようにユーザーのデータが格納されている。
    session[:user_id] = user.id
    session[:name] = user.TwitterID
    session[:T_name] = user.T_name
    session[:img] = user.T_icon
    flash[:notice] = "ログインしました"
    redirect_to("/top")
  end

  def destroy
    session[:user_id] = nil
    session[:g_id] = nil
    session[:user_name] = nil
    session[:user_icon] = nil
    session[:gtoken] = nil
    session[:grefresh] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to("/top")
  end
end
