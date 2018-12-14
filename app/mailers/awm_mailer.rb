class AwmMailer < ApplicationMailer
  def send_mail(awm)
    @awm = awm
    mail(
      from: 'info@vros.jp',
      to:   'info@vros.jp',
      subject: 'お問い合わせ通知'
    )
  end
end
