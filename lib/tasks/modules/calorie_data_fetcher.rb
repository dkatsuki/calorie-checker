class CalorieDataFetcher

  FAT_CALORIE_PER_GRAM = 9
  PROTEIN_CALORIE_PER_GRAM = 4
  CARBOHYDRATE_CALORIE_PER_GRAM = 4
  ALCOHOL_CALORIE_PER_GRAM = 7

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
      'sugar_per_100gram',
      'carbohydrate_per_100gram',
      'fat_per_100gram',
      'protein_per_100gram',
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

  def insert_to_foodstuff
    path = Rails.root.to_s + '/tmp/calorie_data.csv'

    CSV.foreach(path, headers: true) do |row|
      foodstuff = Foodstuff.new

      foodstuff.name = row['name']

      category = case row['category']
        when 'いも・でん粉'
          'いも'
        when '砂糖・甘味'
          '甘味'
        when '豆・種実'
          '豆/種'
        when '飲料・酒'
          '飲料/酒'
        when '調味料・香辛料・油'
          '調味料/油/スパイス'
        when '魚介類'
          '魚介'
        when '乳製品・卵'
          '乳製品/卵'
        else
          row['category']
      end

      foodstuff.category = category
      foodstuff.is_pure = true
      foodstuff.calorie = row['per_100gram_calorie']
      foodstuff.carbohydrate = row['carbohydrate_per_100gram']
      foodstuff.fat = row['fat_per_100gram']
      foodstuff.protein = row['protein_per_100gram']
      foodstuff.sugar = row['sugar_per_100gram']
      foodstuff.add_unit(row['unit_name'], row['unit_gram'])
      if foodstuff.save
      else
        binding.pry
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
      food_name = h1.children.first.content.strip
      calorie_data_container = food_page.at_css('#analysis > table > tr:first-child > td')
      elements = calorie_data_container.children.select {|e| e.name != 'br' && e.is_a?(Nokogiri::XML::Element)}.map(&:content)
      per_100gram_calorie = elements.first.gsub(/kcal/, '').to_f
      unit_gram, unit_name = elements.last.gsub(/\)/, '').split('(').map {|e| e.strip}
      unit_gram = unit_gram.gsub(/g/, '').to_f
      unit_name = unit_gram if unit_name.nil?
      protein_per_unit = food_page.at_css('#protein_content').content.to_f
      fat_per_unit = food_page.at_css('#fat_content').content.to_f
      carbohydrate_per_unit = food_page.at_css('#carb_content').content.to_f

      including_sugar_element = food_page.at_css('#faq > dl > dd:last-child')
      sugar_per_unit = including_sugar_element.at_css('> strong')&.content.match(/量は(.+)g/)&.[](1).to_f

      carbohydrate_calorie_per_unit = carbohydrate_per_unit * CARBOHYDRATE_CALORIE_PER_GRAM
      fat_calorie_per_unit = fat_per_unit * FAT_CALORIE_PER_GRAM
      protein_calorie_per_unit = protein_per_unit * PROTEIN_CALORIE_PER_GRAM

      denominator = carbohydrate_calorie_per_unit + fat_calorie_per_unit + protein_calorie_per_unit

      is_alchol = (denominator < ((per_100gram_calorie * (unit_gram / 100)) / 2))

      carbohydrate_per_100gram = nil
      fat_per_100gram = nil
      protein_per_100gram = nil
      sugar_per_100gram = nil

      if is_alchol
        carbohydrate_per_100gram = carbohydrate_per_unit * (100.to_f / unit_gram)
        fat_per_100gram = fat_per_unit * (100.to_f / unit_gram)
        protein_per_100gram = protein_per_unit * (100.to_f / unit_gram)
        sugar_per_100gram = sugar_per_unit * (100.to_f / unit_gram)
      else
        carbohydrate_calorie_ratio = carbohydrate_calorie_per_unit / denominator
        fat_calorie_ratio = fat_calorie_per_unit / denominator
        protein_calorie_ratio = protein_calorie_per_unit / denominator

        carbohydrate_per_100gram = (per_100gram_calorie * carbohydrate_calorie_ratio) / CARBOHYDRATE_CALORIE_PER_GRAM
        fat_per_100gram = (per_100gram_calorie * fat_calorie_ratio) / FAT_CALORIE_PER_GRAM
        protein_per_100gram = (per_100gram_calorie * protein_calorie_ratio) / PROTEIN_CALORIE_PER_GRAM
        sugar_per_100gram = carbohydrate_per_100gram * (sugar_per_unit / carbohydrate_per_unit)
      end

      {
        id: id,
        name: food_name,
        category: category,
        per_100gram_calorie: per_100gram_calorie.round(2),
        unit_gram: unit_gram,
        unit_name: unit_name,
        sugar_per_unit: sugar_per_unit.round(2),
        carbohydrate_per_unit: carbohydrate_per_unit.round(2),
        fat_per_unit: fat_per_unit.round(2),
        protein_per_unit: protein_per_unit.round(2),
        sugar_per_100gram: sugar_per_100gram.round(2),
        carbohydrate_per_100gram: carbohydrate_per_100gram.round(2),
        fat_per_100gram: fat_per_100gram.round(2),
        protein_per_100gram: protein_per_100gram.round(2),
      }
    end

end