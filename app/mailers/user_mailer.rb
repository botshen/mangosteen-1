class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code
    mail(to: "363088847@qq.com", subject: 'hi')
  end
end
