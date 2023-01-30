module ApplicationHelper
  def each_page_stylesheet_link_tag(path)
    content_for :each_page_stylesheet_link_tag, stylesheet_link_tag(path, "data-turbo-track": "reload")
  end
end
