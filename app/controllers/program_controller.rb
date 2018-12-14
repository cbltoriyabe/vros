class ProgramController < ApplicationController
  require 'yt'
  require 'date'
  require 'json'
  protect_from_forgery :except => [:sample]
  before_action :regcheck, {only: [:registerform, :create]}
  before_action :check_user ,{only: [:edit, :update]}
  before_action :check_program, {only: [:edit, :update, :detail]}
  before_action :set_cache_buster

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def check_user
    checkProgram = Program.find_by(id: params[:id])
    if session[:g_id] != Rails.application.secrets.ManageID1
      if checkProgram.user_id != session[:user_id]
        flash.now[:alert] = "権限がありません"
        redirect_to("/top")
      end
    end
  end

  def regcheck
    if session[:user_id] == nil
      flash.now[:alert] = "ログインしてください"
      redirect_to("/top")
    end
  end

  def check_program
    checkProgram = Program.find_by(id: params[:id])
    if checkProgram != nil
      if checkProgram.delstatus == true
        flash.now[:closed] = "該当する番組は非公開です"
      end
    else
      flash.now[:alert] = "該当する番組はありません"
      redirect_to("/top")
    end
  end

  def top
    gon.program = nil
    #何か問題があった場合は、ここの値を変更すると常にトップページに表示されるようになる。
    #flash[:closed] = "現在不具合が出ておりトップページから日付の遷移が出来ません。ご迷惑おかけして申し訳ございません。"
    #今日の日付を取得
    if params[:days] == nil
      @day = Time.zone.now.to_s[0, 10]
    else
      @day = params[:days]
    end
    
    if session[:user_id] != nil
      user = User.find_by(id: session[:user_id])
      if user.modal == nil
        #trueの場合モーダルを流す
        session[:modal] = true
      end
    end
    
    #取得した日付
    @first_day = Time.parse(@day + " 05:00:00")
    @first_day_u = @first_day.to_i
    #取得した日付の次の日
    @second_day = @day.to_date + 1
    @second_day = Time.parse(@second_day.to_s + " 04:59:59")
    @second_day_u = @second_day.to_i
    select_sql = 'programs.start_time_u , programs.genre , programs.archives , programs.image , programs.like , programs.p_title , programs.tag ,channels.c_icon ,channels.c_name , programs.id'
    @get_program = Program.joins(:channel).select(select_sql).where(start_time_u: @first_day_u..@second_day_u).where(delstatus: 0).order("start_time ASC")
    json = @get_program.to_json
    hash = JSON.parse(json)
    pg_list = []
    hash.each{|key, value|
      pg_list.push(key["id"])
    }
    yokitest = Yoki.select('yokis.id, yokis.program_id').where program_id: pg_list, user_id: session[:user_id]
    json = yokitest.to_json
    yokihash = JSON.parse(json)
    yoki_pg_list = []
    yokitest.each do |yoki|
      yoki_pg_list.push(yoki["program_id"].to_i)
    end
    
    hash.each{|key, value|
      if yoki_pg_list.include?(key["id"])
        key["yoki"] = true
      else
        key["yoki"] = false
      end
    }
    
    @genre = Genre.all.order("sort ASC")
    gon.watch.program = hash.to_json
  end

  def registerform
    if params[:id] != nil
      @program = Program.find_by(id: params[:id])
    else
      @program = Program.new()
    end
    @genre = Genre.all.order("sort ASC")
  end

  def programinfo
    @program = Program.new()
  end

  def create
    #チャンネル登録確認
    Yt.configure do |config|
      config.api_key = Rails.application.secrets.YoutubeApi
    end

    if params[:chaurl] != ""
      #チャンネル初期設定
      @channel = Channel.new
      #Ytジェムでチャンネル情報取得
      channel = Yt::Channel.new id:  params[:chaurl]
      #チャンネル情報DB格納
      @channel.c_url = channel.id
      @channel.c_name = channel.title
      @channel.c_icon = channel.thumbnail_url
      if @channel.save
        @c_id = @channel.id
      else
        @channel = Channel.find_by(c_url: @channel.c_url)
        @c_id = @channel.id
      end
    end

    #終了時間の計算
    if params[:starttime] != ""
      start_time = Time.parse(params[:starttime])
      st = "%s %s" % [params[:date], params[:starttime]]
      start_time_u = Time.parse(st).to_i
      if params[:times] == "0" || params[:times] == "1"
        end_time = ""
      else
        end_time = start_time.since(params[:times].to_i.minutes)
        end_time_u = start_time.since(params[:times].to_i.minutes).to_i
      end
    end

    mem = ""
    mem << params[:liver] + ","
    for i in params[:member] do
      if params[:member][i] != ""
        mem << params[:member][i] + ","
      end
    end

    #番組DBへ登録
    @program = Program.new()
    @program.p_url = params[:prourl]
    @program.p_title = params[:title]
    @program.day = params[:date]
    @program.start_time = start_time
    @program.end_time = end_time
    @program.about = params[:about]
    @program.info = params[:info]
    @program.member = mem
    @program.genre = params[:g_name]
    @program.tag = params[:tags]
    @program.archives = params[:archives]
    @program.channel = @channel
    @program.like = 0
    @program.user_id = session[:user_id]
    @program.update_id = session[:user_id]
    @program.image = params[:image]
    @program.meyasu = params[:times]
    @program.delstatus = params[:delstatus]
    @program.platform = params[:pf]
    @program.start_time_u = start_time_u
    @program.end_time_u = end_time_u

    @program_check = Program.where('channel = ?', @program.channel).where('day = ?', params[:date]).where('start_time = ?', start_time)
    if @program_check.length > 0
      flash[:alert] = "既に同時刻で番組が登録されています"
      @genre = Genre.all.order("sort ASC")
      render "/program/registerform"
    else
      if @program.save
        #セッションリセット
        session[:c_name] = nil
        session[:c_icon] = nil
        session[:c_url] = nil
        session[:c_id] = nil
        flash[:notice] = "番組が登録されました"
        redirect_to("/top")
      else
        flash[:alert] = "必須項目が空白です"
        @genre = Genre.all.order("sort ASC")
        render "/program/registerform"
      end
    end
  end

  def mychannel
    @channel = Channel.new
    account = Yt::Account.new refresh_token: session[:grefresh]
    channel = account.channel
    #チャンネル情報DB格納
    @channel.c_url = channel.id
    @channel.c_name = channel.title
    @channel.c_icon = channel.thumbnail_url
    if @channel.save
      session[:c_name] = @channel.c_name
      session[:c_icon] = @channel.c_icon
      session[:c_url] = @channel.c_url
      session[:c_id] = @channel.id
    else
      @channel_old = Channel.find_by(c_url: @channel.c_url)
      session[:c_name] = @channel_old.c_name
      session[:c_icon] = @channel_old.c_icon
      session[:c_url] = @channel_old.c_url
      session[:c_id] = @channel_old.id
    end
    @program = Program.new()
    @genre = Genre.all.order("sort ASC")
    redirect_to("/program/registerform")
  end

  def detail
    @program = Program.find_by(id: params[:id])
  end

  def edit
    @genre = Genre.all.order("sort ASC")
    @program = Program.find_by(id: params[:id])
  end

  def update
    #チャンネル登録確認
    Yt.configure do |config|
      config.api_key = Rails.application.secrets.YoutubeApi
    end

    if params[:chaurl] != ""
      #チャンネル初期設定
      @channel = Channel.new
      #Ytジェムでチャンネル情報取得
      channel = Yt::Channel.new id:  params[:chaurl]
      #チャンネル情報DB格納
      @channel.c_url = channel.id
      @channel.c_name = channel.title
      @channel.c_icon = channel.thumbnail_url
      if @channel.save
        @c_id = @channel.id
      else
        @channel = Channel.find_by(c_url: @channel.c_url)
        @c_id = @channel.id
      end
    end

    #終了時間の計算
    if params[:starttime] != ""
      start_time = Time.parse(params[:starttime])
      st = "%s %s" % [params[:date], params[:starttime]]
      start_time_u = Time.parse(st).to_i
      if params[:times] == "0" || params[:times] == "1"
        end_time = ""
      else
        end_time = start_time.since(params[:times].to_i.minutes)
        end_time_u = start_time.since(params[:times].to_i.minutes).to_i
      end
    end

    mem = ""
    mem << params[:liver] + ","
    for i in params[:member] do
      if params[:member][i] != ""
        mem << params[:member][i] + ","
      end
    end
    @program = Program.find_by(id: params[:id])
    @program.p_url = params[:prourl]
    @program.p_title = params[:title]
    @program.day = params[:date]
    @program.start_time = start_time
    @program.end_time = end_time
    @program.about = params[:about]
    @program.info = params[:info]
    @program.member = mem
    @program.genre = params[:g_name]
    @program.tag = params[:tags]
    @program.archives = params[:archives]
    @program.channel = @channel
    @program.update_id = session[:user_id]
    @program.image = params[:image]
    @program.meyasu = params[:times]
    @program.delstatus = params[:delstatus]
    @program.start_time_u = start_time_u
    @program.end_time_u = end_time_u
    if params[:pf] != "0"
      @program.platform = params[:pf]
    else
      @program.platform = ""
    end

    @program_check = Program.where('channel = ?', @program.channel).where('day = ?', params[:date]).where('start_time = ?', params[:starttime])
    if @program.save
        #セッションリセット
        session[:c_name] = nil
        session[:c_icon] = nil
        session[:c_url] = nil
        session[:c_id] = nil
        flash[:notice] = "番組編集を完了させました"
        redirect_to("/top")
    else
        flash[:alert] = "必須項目が空白です"
        @genre = Genre.all.order("sort ASC")
        render template: "/program/edit"
    end
  end

  def like
    @program = Program.find_by(id: params[:id])
    if session[:user_id] != nil
      @yoki = Yoki.where(user_id: session[:user_id]).where(program_id: @program.id)
      if @yoki.length == 0
        @yoki_new = Yoki.new(user_id: session[:user_id],program_id: @program.id,check: true)
        @yoki_new.save
        @program.like = @program.like + 1
        @program.save
      end
    end
    
    redirect_to("/program/detail/#{params[:id]}")
      
  end
  
  def like_ajax
    @program = Program.find_by(id: params[:id])
    if session[:user_id] != nil
      @yoki = Yoki.where(user_id: session[:user_id]).where(program_id: @program.id)
      if @yoki.length == 0
        @yoki_new = Yoki.new(user_id: session[:user_id],program_id: @program.id,check: true)
        @yoki_new.save
        @program.like = @program.like + 1
        @program.save
      end
    end
    
    render json: { like: @program.like }
  end

  def del
    @program = Program.find_by(id: params[:id])
    @program.delstatus = true
    if @program.save
      flash[:notice] = "番組を非公開にしました"
      redirect_to("/top")
    else
      flash[:notice] = "エラーが発生しました"
      @genre = Genre.all.order("sort ASC")
      render "/program/registerform"
    end
  end

end
