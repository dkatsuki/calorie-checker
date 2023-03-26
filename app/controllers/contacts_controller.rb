class ContactsController < ApplicationController
  def new
  end

  def create
    if ContactMailer.include_blank?(params)
      flash.now[:error_messages] = ['全ての欄を記入してください']
      render action: :new, status: :unprocessable_entity
    else
      ContactMailer.send_auto_reply(params).deliver_now
      ContactMailer.send_contact_to_inhouse(params).deliver_now
      redirect_to root_path, notice: "お問い合わせが送信されました。"
    end
  end
end