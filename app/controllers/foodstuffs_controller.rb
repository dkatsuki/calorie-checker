class FoodstuffsController < ApplicationController

  private
    def strong_parameters
      result = params.require(:foodstuff).permit(self.model.attribute_names)
      result[:unit_list] = {}
      result[:unit_list].permit!
      params[:foodstuff][:unit_list].each do |key, value|
        result[:unit_list][key] = value
      end
      result
    end
end
