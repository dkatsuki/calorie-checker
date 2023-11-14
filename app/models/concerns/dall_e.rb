# ドキュメント
# https://platform.openai.com/docs/guides/chat/introduction
# https://platform.openai.com/docs/api-reference/images/create
# https://github.com/alexrudall/ruby-openai

require 'base64'

class DallE
  DEFAULT_MODEL = 'dall-e-3'
  attr_accessor :api_key
  attr_reader :client, :http
  @@tmp_storage = Rails.root.to_s + '/tmp/dall_e'

  def @@tmp_storage.join(string)
    @@tmp_storage + string
  end

  def self.tmp_storage
    @@tmp_storage
  end

  def initialize
    @client = OpenAI::Client.new
    @http = HttpClient.new
    @model = DEFAULT_MODEL
  end


  ## 利用可能なサイズの組み合わせ
  # ['256x256', '512x512', '1024x1024', '1024x1792', '1792x1024']
  def generate_image(prompt, size: :small, response_format: 'url') # response_format: 'url' or ''b64_json''

    width = 256
    height = 256

    case size
    when :medium
      width = 512
      height = 512
    when :large
      width = 1024
      height = 1024
    when :portrait
      width = 1024
      height = 1792
    when :landscape
      width = 1792
      height = 1024
    end

    response = @client.images.generate(parameters: {
      model: @model,
      prompt: prompt,
      size: "#{width}x#{height}",
      response_format: response_format
    })

    if response['error'].present?
      return response
    end

    if response_format == 'b64_json' || response_format == 'url'
      response.dig('data', 0, response_format)
    else
      response
    end
  end

  def generate_images(prompt, size: 1024, n:2)
    response = @client.images.generate(parameters: {
      model: @model,
      prompt: prompt,
      size: "#{size}x#{size}",
      n: n
    })
    response['data'].map { |data| data['url'] }
  end

  def generate_and_save_image(prompt, size: 1024)
    url = self.generate_image(prompt, size: size)
    path = download_and_save_image(url)
    path
  end

  def generate_image_valiations(image_path, n: 1)
    response = @client.images.variations(parameters: { model: @model, image: image_path, n: 2 })
    response.dig('data', 0, 'url')
  end

  def edit_image(prompt = "A solid red Ruby on a blue background")
    response = @client.images.edit(parameters: { model: @model, prompt: prompt, image: "image.png", mask: "mask.png" })
    # response.dig('data', 0, 'url')
  end

  private
    def download_and_save_image(url, to_path = nil)
      extention = get_extention(url)
      binary = self.http.get_image(url)
      to_path = @@tmp_storage + '/' + make_random_file_name(extention) if to_path.blank?
      File.open(to_path, 'wb') {|f| f.print(binary) }
      to_path
    end

    def get_extention(string)
      string = string.split('?').first if string.url? && string.include?('?')
      File.extname(string)
    end

    def make_random_file_name(extention)
      SecureRandom.hex(8) + extention
    end

    def write_image(binary)
      to_path = @@tmp_storage + '/' + make_random_file_name('.png')
      File.open(to_path, 'wb') do |f|
        f.print(binary)
      end
      to_path
    end
end
