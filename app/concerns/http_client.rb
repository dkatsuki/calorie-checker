class HttpClient
	attr_accessor :default_origin

	def initialize(default_origin: nil, headers: {})
		@default_origin = default_origin
		@headers = headers
	end

	def parse(page_source, charset: 'utf-8')
		Nokogiri::HTML.parse(page_source, nil, charset)
	end

	def get(target_url, limit = 10)
		set_http_client(target_url)
		response = @http_client.get(@uri.request_uri, @headers)

		case response
		when Net::HTTPSuccess
			response
		when Net::HTTPRedirection
			self.get(response['location'], limit - 1)
		else
			raise RuntimeError.new("HTTP ERROR: code=#{response.code} message=#{response.message}")
		end
	end

	def post(target_url, data = {})
		set_http_client(target_url)
		response = @http_client.post(@uri.request_uri, format_post_data(data), @headers)
		response.is_a?(Net::HTTPSuccess) ? response : nil
	end

	private
		def set_http_client(target_url)
			set_target_uri(target_url)

      @http_client = Net::HTTP.new(@uri.host, @uri.port)

			if target_url.include?('https://')
				@http_client.use_ssl = true
				@http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
		end

		def set_target_uri(url_or_path)
			target_url = @default_origin.present? ? @default_origin + url_or_path : url_or_path
			@uri = URI.parse(target_url)
		end

		def format_post_data(hash)
			post_data_string = ''
			hash.each.with_index do |(key, value), index|
				if index == 0
					post_data_string = "#{key}=#{value}"
				else
					post_data_string = "#{post_data_string}&#{key}=#{value}"
				end
			end
			post_data_string
		end

end