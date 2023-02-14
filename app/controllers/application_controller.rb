class ApplicationController < ActionController::Base

  attr_reader :model

  def initialize
    super
    @model = self.controller_name.singularize.classify.safe_constantize
  end

  def index
    flash.now[:messages] = params[:flash]&.[](:messages)
    @records = self.model.search(params)
    @model = self.model

    respond_to do |format|
      format.html
      format.json { render json: @records }
    end
  end

  def new
    @record = self.model.new
  end

  def create
    @record = self.model.new(self.strong_parameters)

    respond_to do |format|
      if @record.save
        format.html { redirect_to action: :index, flash: {messages: ["#{@record.class.name}のレコード作成に成功しました。"] }}
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    flash.now[:messages] = params[:flash]&.[](:messages)
    @record = self.model.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @record }
    end
  end

  def edit
    @record = self.model.find(params[:id])
  end

  def update
    @record = self.model.find(params[:id])

    respond_to do |format|
      if @record.update(self.strong_parameters)
        format.html { redirect_to action: :index, flash: {messages: ["#{@record.class.name}のレコードの更新に成功しました。"] }}
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @record = self.model.find_by(id: params[:id])

    if @record.destroy
      flash[:message] = "削除に成功しました。"
    else
      flash[:danger] = "削除に失敗しました。"
    end

    respond_to do |format|
      if @record.destroy
        format.html { redirect_to action: :index, flash: {messages: ["#{@record.class.name}の削除に成功しました。"] }, status: :see_other }
        format.json { head :no_content }
      else
        format.html { redirect_to action: :index, flash: {messages: ["#{@record.class.name}の削除に失敗しました。"] }, status: :see_other }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end
end
