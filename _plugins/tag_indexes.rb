Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.map { |p| p.data['tags'] }.reduce(&:|).each do |tag|
    site.pages << TagPage.new(site, site.source, '', tag)
  end
end

class TagPage < Jekyll::Page
  def initialize(site, base, dir, tag)
    @site = site
    @base = base
    @dir = dir
    @name = 'index.html'
    @ext = '.html'
    @url = "/tags/#{Jekyll::Utils.slugify(tag)}/"

    self.read_yaml(File.join(base, '_layouts'), "index.html")
    self.data['layout'] = 'index'
    self.data['title'] = "posts tagged with '#{tag}'"
    self.data['pagination'] = {
      'enabled' => true,
      'collection' => 'posts',
      'sort_field' => 'date',
      'sort_reverse' => true,
      'tag' => tag
    }

    self.process(@name)

    data.default_proc = proc do |_, key|
      site.frontmatter_defaults.find(File.join(dir, name), type, key)
    end

    Jekyll::Hooks.trigger :pages, :post_init, self
  end
end
