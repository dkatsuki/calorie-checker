class FoodstuffsController < ApplicationController

  private
    def strong_parameters
      params.require(:foodstuff).permit(self.model.attribute_names)
    end
end
