class Admin::DishesController < Admin::ApplicationController
  before_action :set_foodstuffs, only: [:new, :edit]

  def set_foodstuffs
    @foodstuffs = self.model.get_association_class(:foodstuffs).all
  end

  def generate_image
    @record = Dish.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: {image: @record.generate_image, extention: 'png'} }
    end
  end

  private
    def strong_parameters
      result = params.require(:dish).permit([
        *self.model.attribute_names,
        recipes_attributes: self.model.get_association_class(:recipes).attribute_names
      ])

      result[:is_open] = result[:is_open] == '1' ? true : false
      result
    end
end
