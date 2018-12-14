class ManagerController < ApplicationController
  protect_from_forgery except: :search # searchアクションを除外
  before_action :user_check

  def user_check
    user1 = Rails.application.secrets.ManageID1
    user2 = Rails.application.secrets.ManageID2
    user3 = Rails.application.secrets.ManageID3
    if session[:g_id] != user1 && session[:g_id] != user2 && session[:g_id] != user3
      flash.now[:alert] = "権限がありません"
      redirect_to("/top")
    end
  end

  def timecheck
    @all_program = Program.all
  end

  def update_program_unix
    #@all_program = Program.where(id: 4149..Float::INFINITY)
    @all_program = Program.all
    @all_program.each_with_index do |program, i|
      star_time = Time.at(program.start_time_u)
      end_time = star_time.since(program.meyasu.to_i.minutes)
      end_time_u = star_time.since(program.meyasu.to_i.minutes).to_i

      program.end_time_u = end_time_u

      if program.save
        logger.debug("成功")
      else
        logger.debug("失敗")
      end
    end

    redirect_to("/top")
  end

  def genre
    @genre = Genre.all
  end

  def genre_reg
    @genre = Genre.new()
    @genre.g_name = params[:genre_name]
    @genre.save
    redirect_to("/manager/genre")
  end

  def genre_del
    @genre = Genre.find_by(id: params[:g_id])
    @genre.destroy
    redirect_to("/manager/genre")
  end

  def manager

  end

  def pro_analy
    con = ActiveRecord::Base.connection
    sql = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS time, count(created_at) AS cnt FROM programs GROUP BY DATE_FORMAT(created_at, '%Y%m%d') ORDER BY time DESC;"
    @result = con.execute(sql)

    #sql2 = "SELECT COUNT(*) FROM programs;"
    #@all_result = con.execute(sql2)
    @all_result = Program.count
  end

  def user_analy
    con = ActiveRecord::Base.connection
    sql = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS time, count(created_at) AS cnt FROM users GROUP BY DATE_FORMAT(created_at, '%Y%m%d') ORDER BY time DESC;"
    @result = con.execute(sql)

    #sql2 = "SELECT COUNT(*) FROM programs;"
    #@all_result = con.execute(sql2)
    @all_result = User.count
  end

  def user_ranking
    con = ActiveRecord::Base.connection
    #sql = "SELECT user_id AS user, user.name AS name ,count(user_id) AS cnt FROM programs left join cate on programs.user_id = user.id;, user GROUP BY user_id ORDER BY cnt DESC;"
    sql = "SELECT programs.user_id AS user, users.name AS name ,count(programs.user_id) AS cnt FROM users left join programs on programs.user_id = users.id GROUP BY user_id ORDER BY cnt DESC;"
    @result = con.execute(sql)

    #sql2 = "SELECT COUNT(*) FROM programs;"
    #@all_result = con.execute(sql2)
    @all_result = User.count
  end

  def channel
    @channel = Channel.all
    @channel_del = Channel.new
    @channel_hide = Channel.new
  end

  def channel_del
    @channel = Channel.find_by(id: params[:c_id])
    @channel.destroy
    redirect_to("/manager/channel")
  end

  def channel_hide

  end

  def user
    @user = User.all
  end

  def user_del
    @user = User.find_by(id: params[:u_id])
    @user.destroy
    redirect_to("/manager/user")
  end

  def program
    @program = Program.all
  end

  def program_del
    @program = Program.find_by(id: params[:p_id])
    @program.destroy
    redirect_to("/manager/program")
  end
end
