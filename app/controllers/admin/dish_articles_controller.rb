class Admin::DishArticlesController < Admin::ApplicationController
  before_action :set_dishes, only: [:new, :edit]

  def set_dishes
    @dishes = self.model.get_association_class(:dish).all
  end

  private
    def strong_parameters
      result = params.require(:dish_article).permit(self.model.attribute_names)
    end
end
