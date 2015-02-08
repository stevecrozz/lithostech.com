module Jekyll
  class TagIndexes < Generator
    safe true

    def generate(site)
      site.tags.each do |tag|
        build_subpages(site, tag)
      end
    end

    def build_subpages(site, posts)
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }
      paginate(site, posts)
    end

    def paginate(site, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts[1], site.config['paginate'].to_i)

      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts[1], pages)
        path = "/tags/#{posts[0]}"
        if num_page > 1
          path = path + "/page/#{num_page}"
        end
        newpage = GroupSubPage.new(site, site.source, path, posts[0])
        newpage.pager = pager
        site.pages << newpage
      end
    end
  end

  class GroupSubPage < Page
    def initialize(site, base, dir, val)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "index.html")
      self.data["grouptype"] = 'tags'
      self.data['tags'] = val
    end
  end
end
