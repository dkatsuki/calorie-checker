class Admin::DishArticlesController < Admin::ApplicationController
  before_action :set_dishes, only: [:new, :edit, :update, :create]

  def parse_markdown
    respond_to do |format|
      format.html
      format.json { render json: {html: DishArticle.to_html(params[:mark_down_text])} }
    end
  end

  def generate_article
    dish_article = DishArticle.find_or_initialize_by(dish_id: params[:dish_id])
    article_body = dish_article.generate_article
    respond_to do |format|
      format.json { render json: { article_body: article_body } }
    end
  end

  def set_dishes
    @dishes = self.model.get_association_class(:dish).all
  end

  private
    def strong_parameters
      result = params.require(:dish_article).permit(self.model.attribute_names)
    end
end
