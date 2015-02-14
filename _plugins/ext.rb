require 'jekyll-assets'

if Jekyll.env == 'production'
  require 'jekyll-sitemap'
  require 'octopress-minify-html'
else
  require 'pry'
  Jekyll.configuration['assets']['js_compressor'] = nil
  Jekyll.configuration['assets']['css_compressor'] = nil
end
