class LoginController < ApplicationController

  PER = 10

  def login
    @user = User.new
  end

  def userview
    case params[:sort]
      when "1" then
        #放送日順（降順）
        @program_s = Program.where(user_id: session[:user_id]).group(:id).order('day DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "2" then
        #放送日順（昇順）
        @program_s = Program.where(user_id: session[:user_id]).group(:id).group(:id).order('day ASC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "3" then
        #登録順（降順）
        @program_s = Program.where(user_id: session[:user_id]).group(:id).group(:id).order('created_at DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "4" then
        #登録順（昇順）
        @program_s = Program.where(user_id: session[:user_id]).group(:id).group(:id).order('created_at ASC')
        @program_p = @program_s.page(params[:page]).per(PER)
      else
        #放送日順（降順）
        @program_s = Program.where(user_id: session[:user_id]).group(:id).group(:id).order('day DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
    end

  end

  def yokiview
    #DB取得
    pg_list = []
    @yoki = Yoki.where(user_id: session[:user_id])
    @yoki.each do |yoki|
      pg_list.push(yoki.program_id)
    end
    logger.debug("pg_list")
    logger.debug pg_list
    @program = Program.where(id: pg_list).where(delstatus: false)
    @program = @program.order('created_at DESC')
    @program_p = @program.page(params[:page]).per(PER)
  end

  def google

  end

end
