class ContactsController < ApplicationController
  def new
  end

  def create
    ContactMailer.send_auto_reply(params).deliver_now
		ContactMailer.send_contact_to_inhouse(params).deliver_now
    redirect_to root_path, notice: "お問い合わせが送信されました。"
  end
end