class DishArticle < ApplicationRecord
	include MarkDownAttachment

  @@japanese_name = '料理記事'
  attr_reader :gpt

  belongs_to :dish, class_name: "Dish"
  validate :no_h1_heading, if: :including_h1_heading?

  class << self
    def japanese_name
      @@japanese_name
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
        text: "#{dish.name}のカロリーと糖質"
      },
      {
        tag_name: 'h3',
        text: "#{dish.name}#{dish.unit}あたりのカロリーとPFCバランスについて"
      },
      {
        tag_name: 'h3',
        text: "#{dish.name}と他の類似食材との比較"
      },
      {
        tag_name: 'h2',
        text: "#{dish.name}の栄養成分と効能"
      },
      {
        tag_name: 'h3',
        text: "主な栄養素と美容効果など"
      },
      {
        tag_name: 'h3',
        text: "その他の栄養素"
      },
      {
        tag_name: 'h2',
        text: "ダイエットにおすすめの#{dish.name}の食べ方・調理方法"
      },
      {
        tag_name: 'h3',
        text: "低カロリーな調理方法"
      },
      {
        tag_name: 'h3',
        text: "カロリーを抑えた#{dish.name}のレシピ"
      },
      {
        tag_name: 'h2',
        text: "#{dish.name}の注意点"
      },
      {
        tag_name: 'h3',
        text: "特有の注意事項（アレルギー、成分など）"
      },
      {
        tag_name: 'h3',
        text: "調理における注意点"
      },
      {
        tag_name: 'h2',
        text: "まとめ"
      },
    ]
  end

  def get_table_of_contents_text
    self.get_default_headers.inject('') do |result, current|
      if current[:tag_name] == 'h3'
        result + "#{current[:text]}\n"
      else
        result
      end
    end
  end

  def get_article_part_order_text(target_header)
    dish_name = self.dish.name
    <<-EOS
      # 命令書:
      あなたは超一流のプロの記事ライターです。
      以下の「前提条件」「制約条件」「使用する予定の目次」をもとに記事テキストを出力してください。
      但し、まずは「対象見出し」の部分の記事テキストのみを出力してください。

      # 対象見出し
      #{target_header}

      # 前提条件
      ・カロリーやPFCバランス、糖質やレシピなどの情報をまとめたwebサイトにおける記事である
      ・想定している読者はダイエットをしている人や健康的な体づくりを行なっている人である
      ・SEO集客を行なっているwebサイトにおける記事である
      ・想定される検索キーワードは「#{dish_name} カロリー」「#{dish_name} 糖質」といったワードである

      # 制約条件:
      ・想定している読者が望んでいるであろう情報を盛り込む事
      ・対象見出し以外の見出しに関するコンテンツは入れない事
      ・対象見出しで指定された見出しに対応する記事テキスト以外のテキストは出力しない事
      ・「キロカロリー」という文言を使う場合は「kcal」という表記を使用する事
      ・chat gptで出力したと判定されにくい様な文章にする事
      ・見出しに使われている文言はそのまま本文で使わない事

      # 目次
      #{self.get_table_of_contents_text}

      # 出力文:
    EOS
  end

  def order_article_part(target_header)
    if @gpt.blank?
      @gpt = ChatGpt.new
    else
      @gpt.stash_history
    end

    order_text = self.get_article_part_order_text(target_header)
    response = gpt.chat(order_text)
  end

  def order_article
    target_header_text_list = self.get_default_headers.map do |header_data|
      header_data[:tag_name] == 'h3' ? header_data[:text] : nil
    end.compact

    target_header_text_list.inject('') do |result, target_header_text|
      result + "#{self.order_article_part(target_header_text)}\n\n"
    end
  end

end
