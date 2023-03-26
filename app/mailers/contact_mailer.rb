class ContactMailer < ApplicationMailer

  def self.include_blank?(mail_info)
    mail_info[:email].blank? ||
    mail_info[:name].blank? ||
    mail_info[:subject].blank? ||
    mail_info[:body].blank?
  end

	def default_from
		Rails.application.credentials.config[:smtp][:user_name]
	end

	def template_path
		Rails.root.to_s + '/app/views/contact_mailer'
	end

	def send_auto_reply(mail_info)
		@email = mail_info[:email]
		@name = mail_info[:name].present? ? mail_info[:name] : @email.dup
		@subject = mail_info[:subject]
		@body = mail_info[:body]
		mail(
			to: @email,
			subject: '【カロリーチェッカー】自動返信/お問い合わせありがとうございます。',
		)
	end

	def send_contact_to_inhouse(mail_info)
		@subject = mail_info[:subject]
		@email = mail_info[:email]
		@name = mail_info[:name].present? ? mail_info[:name] : '未入力'
		@body = mail_info[:body]
		mail(
			to: default_from,
			subject: '【新規問い合わせ】',
		)
	end
end
