class ApplicationController < ActionController::Base

  attr_reader :model

  def initialize
    super
    @model = self.controller_name.singularize.classify.safe_constantize
  end

  def index
    @records = self.model.all
  end

  def new
    @record = self.model.new
  end

  def create
    @record = self.model.new(self.strong_parameters)

    if @record.save
      redirect_to action: :index
    else
      render action: :new
    end
  end
end
