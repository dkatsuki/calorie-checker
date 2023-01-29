# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

style_sheet_dir = Rails.root.to_s + "/app/assets/stylesheets"

paths = Dir.glob('**/*', File::FNM_DOTMATCH, base: style_sheet_dir).map do |file|
  file_path = File.join(style_sheet_dir, file)
  next nil unless file_path.include?('.scss')
  result = file_path.gsub(Regexp.new(style_sheet_dir), '').gsub(/\.scss/, '.css')
  result.slice!(0)
  result
end.compact

Rails.application.config.assets.precompile += ['*.js', '*.css', *paths]
