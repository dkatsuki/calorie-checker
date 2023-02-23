class Admin::DishesController < Admin::ApplicationController
  before_action :set_foodstuffs, only: [:new, :edit]

  def set_foodstuffs
    @foodstuffs = self.model.get_association_class(:foodstuffs).all
  end

  private
    def strong_parameters
      result = params.require(:foodstuff).permit([
        *self.model.attribute_names,
        recipes_attributes: self.model.get_association_class(:recipes).attribute_names
      ])
    end
end
