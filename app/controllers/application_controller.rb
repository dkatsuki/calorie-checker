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

  def show
    flash.now[:messages] = params[:flash]&.[](:messages)
    @record = self.model.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @record }
    end
  end
end
