module MarkDownAttachment
  extend ActiveSupport::Concern
  attr_reader :md_parser

  included do
    after_initialize do |instance|
    end
  end

  module ClassMethods
    # ここに定義したメソッドはクラスメソッドとしてincludeされる
    def mark_down_column
      :body
    end
  end

  def new_md_parser
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      fenced_code_blocks: true,
      autolink: true,
      tables: true
    )
  end

  def htmlized_body
    return @htmlized_body if @htmlized_body.present?
    @htmlized_body = self.to_html(self.body)
  end

  def to_html(md_text)
    @md_parser = self.new_md_parser if @md_parser.blank?
    @md_parser.render(md_text)
  end
end