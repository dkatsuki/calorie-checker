class DishArticle < ApplicationRecord
	include MarkDownAttachment

  @@japanese_name = '料理記事'
  attr_reader :gpt

  belongs_to :dish, class_name: "Dish"
  # validate :no_h1_heading, if: :including_h1_heading?

  class << self
    def japanese_name
      @@japanese_name
    end

    def search(params)
      query = self.all

      if params[:dish]&.[](:name).present?
        query = query.eager_load(:dish) unless query.eager_load_values.include?(:dishes)
        query = query.where('dishes.name LIKE ?', "%#{sanitize_sql_like(params[:dish][:name].to_s)}%")
      end

      sort_options = []

      if params[:sort].is_a? Array
        sort_options = params[:sort]
      elsif params[:sort]&.[](:key).present? && params[:sort]&.[](:order).present?
        sort_options = [params[:sort]]
      end

      sort_options << {key: :id, order: :asc} if sort_options.present?

      sort_options.each do |sort_option|
        key = sort_option[:key].to_sym
        order = sort_option[:order].to_sym
        query = query.order(key => order)
      end

      limit = params[:limit].present? ? params[:limit].to_i : 10000
      query = query.limit(limit)

      if params[:page].present?
        page = params[:page].to_i
        query = query.offset(limit * (page - 1)) if page != 0
      end

      query
    end

  end

  def body=(value)
    doc = self.class.giko_giko(self.class.to_html(value))
    self.headers = doc.css('h2, h3').map {|e| {tag_name: e.name, text: e.text} }
    super(value)
  end

  def no_h1_heading
    errors.add(:body, "h1タグを含めることはできません。")
  end

  def including_h1_heading?
    rows = self.body.lines
    rows.each do |row|
      return true if row =~ /^#\s/
    end
    false
  end

  def get_default_headers(english_dish_name = nil, english_dish_unit = nil)
    dish = self.dish
    return false if dish.blank?
    [
      {
        tag_name: 'h2',
        text: "#{dish.name}#{dish.unit}あたりのカロリーとPFCバランスについて",
        english_text: "Calories per #{english_dish_unit} of #{english_dish_name} and PFC balance",
      },
      {
        tag_name: 'h2',
        text: "主な栄養素と美容効果など",
        english_text: "Main nutrients and cosmetic effects, etc.",
      },
      {
        tag_name: 'h2',
        text: "その他の栄養素",
        english_text: "Other Nutrients",
      },
      {
        tag_name: 'h2',
        text: "#{dish.name}と他の類似食材との比較",
        english_text: "Comparison of #{english_dish_name} with Other Similar Ingredients",
      },
      {
        tag_name: 'h2',
        text: "相性の良い食材",
        english_text: "Foods that go well together",
      },
      {
        tag_name: 'h2',
        text: "低カロリーな調理方法",
        english_text: "Low-calorie cooking methods",
      },
      {
        tag_name: 'h2',
        text: "カロリーを抑えた#{dish.name}のレシピ",
        english_text: "Recipe for #{english_dish_name} with Reduced Calories",
      },
      {
        tag_name: 'h2',
        text: "どれくらい保存できるか、賞味期限は？",
        english_text: "How long can it be stored and what is its shelf life?",
      },
      {
        tag_name: 'h2',
        text: "特有の注意事項（アレルギー、成分など）",
        english_text: "Special precautions (allergies, ingredients, etc.)",
      },
      {
        tag_name: 'h2',
        text: "調理における注意点",
        english_text: "Precautions in Cooking",
      },
    ]
  end

  def get_table_of_contents_text
    self.get_default_headers.inject('') do |result, current|
      result + "#{current[:text]}\n"
    end
  end

  def get_english_table_of_contents_text
    deep_l = DeepLClient.new
    english_dish_name = deep_l.to_english(self.dish.name)
    english_dish_unit = deep_l.to_english(self.dish.unit)
    self.get_default_headers(english_dish_name, english_dish_unit).inject('') do |result, current|
      result + "#{current[:english_text]}\n"
    end
  end

  def get_article_japanese_prompt
    <<-EOS
      # 命令書:
      あなたは超一流のプロの記事ライターです。
      以下の目次をもとに記事を書いてください。
      ただし、制約条件を踏まえてください。

      # 制約条件:
      ・想定している読者が望んでいるであろう情報を盛り込む事
      ・chat gptで出力したと判定されにくい様な文章にする事
      ・見出しに使われている文言はそのまま本文で使わない事
      ・マークダウンテキスト形式で書くこと、ただし、見出しはh1を使わずにh2から使用すること

      # 目次
      #{self.get_table_of_contents_text}

      # 出力文:
    EOS
  end

  def get_article_english_prompt
    deep_l = DeepLClient.new
    <<-EOS
      # Instructions:.
      You are a top-notch professional article writer.
      Write an article based on the following table of contents.
      However, please take into account the constraints.

      # Constraints:.
      Include information that your intended readers will want.
      If you use the term "kilocalories," please use "kcal" instead.
      The text should be such that it is difficult to be judged as output by chat gpt.
      Do not use headlines in the body of the text.
      Write in markdown text format, but use headings from h2 instead of h1

      # Table of Contents
      #{self.get_english_table_of_contents_text}

      # Output text:.
    EOS
  end

  def generate_article
    if @gpt.blank?
      @gpt = ChatGpt.new
    else
      @gpt.stash_history
    end

    deep_l = DeepLClient.new
    prompt = self.get_article_english_prompt
    response = @gpt.chat(prompt)
    response = deep_l.to_japanese(response)
    response
  end

end
