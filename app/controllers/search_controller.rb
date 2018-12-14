class SearchController < ApplicationController
  protect_from_forgery :except => [:search]
  #ページに載せる件数
  PER = 10

  def search
    word = "%" + params[:word].gsub(/#/, '') + "%"
    word.gsub(/%/, '％')
    logger.debug(word)
    case params[:sort]
      when "1" then
        #放送日順（降順）
        @channel = Channel.where('c_name like ?', word)
        @program_s = Program.where('p_title like ? OR about like ? OR tag like ? OR member like ?', word, word, word, word).where('archives = ?', "true").where('delstatus = ?', 0).group(:id).order('day DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "2" then
        #放送日順（昇順）
        @program_s = Program.where('p_title like ? OR about like ? OR tag like ? OR member like ?', word, word, word, word).where('archives = ?', "true").where('delstatus = ?', 0).group(:id).order('day ASC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "3" then
        #放送日順（降順）
        @program_s = Program.where('p_title like ? OR about like ? OR tag like ? OR member like ?', word, word, word, word).where('archives = ?', "true").where('delstatus = ?', 0).group(:id).order('created_at DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
      when "4" then
        #放送日順（昇順）
        @program_s = Program.where('p_title like ? OR about like ? OR tag like ? OR member like ?', word, word, word, word).where('archives = ?', "true").where('delstatus = ?', 0).group(:id).order('created_at ASC')
        @program_p = @program_s.page(params[:page]).per(PER)
      else
        #放送日順（降順）
        @program_s = Program.where('p_title like ? OR about like ? OR tag like ? OR member like ?', word, word, word, word).where('archives = ?', "true").where('delstatus = ?', 0).group(:id).order('day DESC')
        @program_p = @program_s.page(params[:page]).per(PER)
    end
    #パラメータの値保管
    @word = params[:word]
  end
end
