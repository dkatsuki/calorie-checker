module ApplicationHelper
  def each_page_stylesheet_link_tag(path)
    content_for :each_page_stylesheet_link_tag, stylesheet_link_tag(path, "data-turbo-track": "reload")
  end

  def each_page_javascript_import_tag(path)
    content_for :each_page_javascript_import do
      javascript_import_module_tag(path)
    end
  end
end
