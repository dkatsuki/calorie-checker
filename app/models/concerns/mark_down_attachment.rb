module MarkDownAttachment
  extend ActiveSupport::Concern
  attr_reader :md_parser

  included do
    # after_initialize do |instance|
    # end
  end

  module ClassMethods
    # ここに定義したメソッドはクラスメソッドとしてincludeされる
    def mark_down_column
      :body
    end

    def to_html(md_text)
      return '' if md_text.blank?
      md_parser = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,
        fenced_code_blocks: true,
        autolink: true,
        tables: true
      )
      md_parser.render(md_text)
    end

    def giko_giko(raw_html)
      Nokogiri::HTML.parse(raw_html)
    end
  end

  def htmlized_body
    return @htmlized_body if @htmlized_body.present?
    @htmlized_body = self.class.to_html(self.body)
  end
end