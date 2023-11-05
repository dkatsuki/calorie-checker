class CalorieDataFetcher
  def initialize
    @api_origin = Rails.application.credentials.dig(:api_origins, :calorie_data_source)
    @client = HttpClient.new
  end

  def fetch_htmls
    directory = Rails.root.to_s + '/tmp/fetched_calorie_data_source_htmls'
    fetched_ids = Dir.glob("#{directory}/*.html").map {|path| path.match(/\/([0-9]+)\.html/)[1] }

    food_data_list = []

    top_page = fetch(@api_origin)
    category_list = scrape_category_list(top_page)
    category_list.each do |category|
      category_page = fetch(category[:url])
      food_urls = scrape_food_urls(category_page)
      food_urls.each do |food_url|
        id = food_url.match(/\/([0-9]+)\//)[1]
        next if fetched_ids.include?(id)

        sleep(2)

        begin
          food_page = fetch(food_url)
        rescue => e
          next
        end

        File.open("#{directory}/#{id}.html", 'w') do |file|
          file.puts(food_page.to_html)
        end
      end
    end

  end

  def scrape_htmls
    directory = Rails.root.to_s + '/tmp/fetched_calorie_data_source_htmls'
    file_paths = Dir.glob("#{directory}/*.html")

    result_path = Rails.root.to_s + '/tmp/calorie_data.csv'

    headers = [
      'id',
      'name',
      'category',
      'per_100gram_calorie',
      'unit_gram',
      'unit_name',
      'sugar_per_unit',
      'carbohydrate_per_unit',
      'fat_per_unit',
      'protein_per_unit',
    ]

    CSV.open(result_path, 'w') do |csv|
      csv << headers
    end

    CSV.open(result_path, 'a') do |csv|
      file_paths.each do |file_path|
        id = file_path.match(/\/([0-9]+)\.html/)[1]
        food_page = Nokogiri::HTML.parse(File.read(file_path))
        food_data = scrape_food_data(food_page, id)
        csv << headers.map { |header| food_data[header.to_sym] }
      end
    end
  end

  private
    def fetch(url)
      response = @client.get(url)
      @client.parse(response.body)
    end

    def scrape_category_list(top_page)
      selector = '#contentsTokushuRight > aside:nth-child(2) > div.menuContents > ul > li:nth-child(2)'
      categories_wrapper = top_page.at_css(selector)
      category_links = categories_wrapper.css('li > a')

      list = []

      category_links.each do |category_link|
        category_name = category_link.content
        category_id = category_link['href'].match(/\/([0-9]+)\//)[1]
        list << {
          id: category_id,
          name: category_name,
          url: @api_origin + "/category/#{category_id}/",
        }
      end
      list
    end

    def scrape_food_urls(category_page)
      page_urls = category_page.css('#pager > a').map {|a_tag| @api_origin + a_tag['href'] }.uniq

      results = []
      page_urls.each do |page_url|
        sleep(1.0)
        page = fetch(page_url)
        a_tags = page.css('#foodList > ul > li > a')
        a_tags.each do |a_tag|
          results << @api_origin + a_tag['href']
        end
      end
      results
    end

    def scrape_food_data(food_page, id = nil)
      category = food_page.at_css('#centerPositionCcds > div.breadcrumb.subBreadcrumb > div:nth-child(2) > a > span')&.content
      h1 = food_page.at_css('#contentsPadding > div.clearfix h1')
      food_name = h1.children.first.content
      calorie_data_container = food_page.at_css('#analysis > table > tr:first-child > td')
      elements = calorie_data_container.children.select {|e| e.name != 'br' && e.is_a?(Nokogiri::XML::Element)}.map(&:content)
      per_100gram_calorie = elements.first
      unit_gram, unit_name = elements.last.gsub(/\)/, '').split('(').map {|e| e.strip}
      unit_name = unit_gram if unit_name.nil?
      protein = food_page.at_css('#protein_content').content
      fat = food_page.at_css('#fat_content').content
      carbohydrate = food_page.at_css('#carb_content').content

      including_sugar_element = food_page.at_css('#faq > dl > dd:last-child')
      sugar_per_unit = including_sugar_element.at_css('> strong')&.content.match(/量は(.+)g/)&.[](1)

      {
        id: id,
        name: food_name,
        category: category,
        per_100gram_calorie: per_100gram_calorie,
        unit_gram: unit_gram,
        unit_name: unit_name,
        sugar_per_unit: sugar_per_unit,
        carbohydrate_per_unit: carbohydrate,
        fat_per_unit: fat,
        protein_per_unit: protein,
      }
    end

end