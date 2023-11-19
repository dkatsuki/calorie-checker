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

  def get_default_headers
    dish = self.dish
    return false if dish.blank?
    [
      {
        tag_name: 'h2',
        text: "#{dish.name}#{dish.unit}あたりのカロリーとPFCバランスについて"
      },
      {
        tag_name: 'h2',
        text: "主な栄養素と美容効果など"
      },
      {
        tag_name: 'h2',
        text: "その他の栄養素"
      },
      {
        tag_name: 'h2',
        text: "#{dish.name}と他の類似食材との比較"
      },
      {
        tag_name: 'h2',
        text: "相性の良い食材"
      },
      {
        tag_name: 'h2',
        text: "低カロリーな調理方法"
      },
      {
        tag_name: 'h2',
        text: "カロリーを抑えた#{dish.name}のレシピ"
      },
      {
        tag_name: 'h2',
        text: "どれくらい保存できるか、賞味期限は？"
      },
      {
        tag_name: 'h2',
        text: "特有の注意事項（アレルギー、成分など）"
      },
      {
        tag_name: 'h2',
        text: "調理における注意点"
      },
    ]
  end

  def get_table_of_contents_text
    self.get_default_headers.inject('') do |result, current|
      if current[:tag_name] == 'h2'
        result + "#{current[:text]}\n"
      else
        result
      end
    end
  end

  def generate_article_part(target_header)
    if @gpt.blank?
      @gpt = ChatGpt.new
    else
      @gpt.stash_history
    end

    order_text = self.get_article_part_order_text(target_header)
    response = @gpt.chat(order_text)
    response
  end

  def get_article_order_text
    dish_name = self.dish.name
    <<-EOS
      # 命令書:
      あなたは超一流のプロの記事ライターです。
      以下の目次をもとに記事を書いてください。
      ただし、制約条件を踏まえてください。

      # 制約条件:
      ・想定している読者が望んでいるであろう情報を盛り込む事
      ・対象見出し以外の見出しに関するコンテンツは入れない事
      ・対象見出しで指定された見出しに対応する記事テキスト以外のテキストは出力しない事
      ・「キロカロリー」という文言を使う場合は「kcal」という表記を使用する事
      ・chat gptで出力したと判定されにくい様な文章にする事
      ・見出しに使われている文言はそのまま本文で使わない事
      ・具体例や客観的なデータや統計データなど信頼できる機関が出しているデータがある場合はそれを表示してください
      ・マークダウンテキスト形式で書くこと、ただし、見出しはh1を使わずにh2から使用すること

      # 目次
      #{self.get_table_of_contents_text}

      # 出力文:
    EOS
  end

  def generate_article
    if @gpt.blank?
      @gpt = ChatGpt.new
    else
      @gpt.stash_history
    end

    order_text = self.get_article_order_text
    deep_l = DeepLClient.new
    order_text = deep_l.to_english(order_text)
    response = @gpt.chat(order_text)
    response = deep_l.to_japanese(response)
    response
  end

end
