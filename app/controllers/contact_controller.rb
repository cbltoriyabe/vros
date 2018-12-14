class ContactController < ApplicationController
  def form
    @contact = Contact.new()
  end

  def create
    @contact = Contact.new()
    @contact.genre = params[:genre]
    @contact.name = params[:name]
    @contact.mail = params[:mail]
    @contact.com = params[:com]
    if verify_recaptcha(model: @contact) && @contact.save
      notifier = Slack::Notifier.new('https://hooks.slack.com/services/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') #事前準備で取得したWebhook URL
      text = "問い合わせ番号：" + @contact.id.to_s + "\n" + @contact.name + "さんから、" + @contact.genre + "についてお問い合わせが着ていますよ。\nお問い合わせ内容は\n" + @contact.com + "\nだそうです！\n"
      notifier.ping(text)

      mail_text = "問い合わせ番号：" + @contact.id.to_s + "\n\n名前：" + @contact.name + "\n\nメールアドレス："  + @contact.mail + "\n\n内容：\n" + @contact.com + "\n"
      mail = Awm.new(name: @contact.name, message: mail_text)
      AwmMailer.send_mail(mail).deliver_now
      mail.save
      render "contact/thank"
    else
      render "contact/form"
    end
  end

  def thank

  end
end
