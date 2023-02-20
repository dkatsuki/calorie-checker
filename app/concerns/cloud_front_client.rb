class CloudFrontClient
	# 公式APIリファレンス
	# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html

	attr_reader :client, :files_distribution_id

	def initialize(distribution_id = nil)
		config = Rails.application.credentials.config[:aws]
		@client = Aws::CloudFront::Client.new(
			region: 'ap-northeast-1',
			access_key_id: config[:access_key_id],
			secret_access_key: config[:secret_access_key],
		)
		@files_distribution_id = distribution_id || config[:cloud_front][:default_distribution_id]
	end

	def create_invalidation(*target_paths)
		@client.create_invalidation({
			distribution_id: @files_distribution_id,
			invalidation_batch: {
				paths: {
					quantity: target_paths.length,
					items: target_paths,
				},
				caller_reference: unix_time_stamp,
			},
		})
	end

	private
		def unix_time_stamp
			Time.now.to_i.to_s
		end
end