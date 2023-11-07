class Admin::DishesController < Admin::ApplicationController
  before_action :set_foodstuffs, only: [:new, :edit]

  def set_foodstuffs
    @foodstuffs = self.model.get_association_class(:foodstuffs).all
  end

  def generate_image
    # flash.now[:messages] = params[:flash]&.[](:messages)
    # @records = self.model.search(params)

    respond_to do |format|
      format.html
      format.json { render json: {test: 1} }
    end
  end

  private
    def strong_parameters
      result = params.require(:dish).permit([
        *self.model.attribute_names,
        recipes_attributes: self.model.get_association_class(:recipes).attribute_names
      ])
    end
end
