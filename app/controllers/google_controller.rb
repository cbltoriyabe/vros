class GoogleController < ApplicationController
  require 'google/apis/youtube_v3'
  require 'active_support/all'
  require 'json'
  require 'yt'

  def callback_auth
    logger.debug("login処理---------------------------------------------------------------------")
    if params[:error] != "access_denied"
      #JSONファイルの読み取り
      #ディレクトリは最上位
      File.open("GoogleAPI.json") do |file|
        @gapi = JSON.parse(file.read)
      end
      #リダイレクトURL

      #開発
      #rurl = 'http://192.168.33.10.xip.io:3000/login/google'
      #Clouf9
      #rurl = 'https://07da81f08b7442f38bed3ff7dc937b32.vfs.cloud9.ap-southeast-1.amazonaws.com/login/google'
      #本番
      rurl = 'http://vros.jp/login/google'

      #Google APIリクエストURL
      uri = URI.parse @gapi['web']['token_uri']
      #hash生成
      post_params = Hash.new
      #hashコードをPOSTに定義
      post_params.store('code', params[:code])
      logger.debug(params[:code])
      #クライアントID指定
      post_params.store('client_id', @gapi['web']['client_id'])
      #クライアントシークレット指定
      post_params.store('client_secret', @gapi['web']['client_secret'])
      #リダイレクト指定
      post_params.store('redirect_uri', rurl)
      post_params.store('grant_type', 'authorization_code')
      post_params.store('access_typ', 'offline')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.set_debug_output $stderr
      req = Net::HTTP::Post.new uri.path
      req.set_form_data(post_params)
      logger.debug('http start前')
      http.start do |h|
        response = h.request(req)
        result = JSON.parse(response.body)
        logger.debug('result')
        logger.debug(result)
        logger.debug('response')
        logger.debug(response)
        # ここにログインしているユーザーのアクセストークンとリフレッシュトークンを保管
        access_token = result['access_token']
        refresh_token = result['refresh_token']

        #取得したアクセストークンからプロファイルの情報を取得する。
        uri2 = URI.parse('https://www.googleapis.com/plus/v1/people/me/')
        query_arr = (uri2.query ? URI.decode_www_form(uri.query) : []) << ["access_token", access_token]
        uri2.query = URI.encode_www_form(query_arr)
        account = JSON.parse(Net::HTTP.get(uri2))
        logger.debug(account)

        # ユーザーテーブル作成
        @user = User.new()
        @user.name = account['displayName']
        @user.g_id = account['id']

        if @user.save
          logger.debug("@user")
          logger.debug(@user)
          userid = @user.id

          # トークンをDB保存
          @g_token = GToken.new()
          @g_token.g_id = account['id']
          logger.debug(@g_token.access_token)
          logger.debug("access_token")
          logger.debug(access_token)
          @g_token.access_token = access_token
          @g_token.refresh_token = refresh_token
          if @g_token.save
            logger.debug("@g_token")
            logger.debug(@g_token)
          else
            @user.destroy
            flash[:alert] = "ログイン中にエラーが発生しました"
            logger.debug("login処理エラー---------------------------------------------------------------------")
            redirect_to("/top")
          end

          # Googleテーブル保存
          @g_user = GoogleT.new()
          @g_user.g_id = account['id']
          @g_user.User_id = userid
          @g_user.g_name = account['displayName']
          @g_user.g_icon = account['image']['url']
          if @g_user.save
            logger.debug("@g_user")
            logger.debug(@g_user)
          else
            @user.destroy
            @g_token.destroy
            flash[:alert] = "ログイン中にエラーが発生しました"
            logger.debug("login処理エラー---------------------------------------------------------------------")
            redirect_to("/top")
          end

          #　ユーザー情報をセッション管理
          session[:user_id] = userid
          session[:g_id] = account['id']
          session[:user_name] = account['displayName']
          session[:user_icon] = account['image']['url']
          session[:gtoken] = access_token
          session[:grefresh] = refresh_token
        else
          @old_user = User.find_by(g_id: @user.g_id)
          session[:user_id] = @old_user.id
          session[:g_id] = @user.g_id
          session[:user_name] = @old_user.name
          session[:user_icon] = GoogleT.select(:g_icon).find_by(g_id: @old_user.g_id).g_icon
          session[:gtoken] = GToken.select(:access_token).find_by(g_id: @old_user.g_id).access_token
          session[:grefresh] = GToken.select(:refresh_token).find_by(g_id: @old_user.g_id).refresh_token
        end

      end
      # トップページへ遷移
      flash[:notice] = "ログインしました"
      redirect_to("/top")
      logger.debug("login処理正常終了---------------------------------------------------------------------")
    else
      flash[:alert] = "ログイン中にエラーが発生しました"
      redirect_to("/top")
      logger.debug("login処理エラー---------------------------------------------------------------------")
    end
  end
end
