module Jekyll
  class AtomBuilder < Generator
    safe true

    def configure(site)
      site.config['feed'] ||= {}
      site.config['feed']['layout'] ||= 'feed.xml'
      site.config['feed']['name'] ||= 'feed'
    end

    def generate(site)
      configure(site)
      posts = site.posts.sort_by { |p| -p.date.to_f }
      posts.each { |p| p.content = p.transform }
      paginate(site, posts)
    end

    def paginate(site, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts, site.config['paginate'].to_i)

      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts, pages)
        site.pages << AtomPage.new(site, site.source, pager)
      end
    end
  end

  class AtomPage < Page
    def initialize(site, base, pager)
      @site = site
      @base = base
      @pager = pager

      @dir = feed_dir(site, pager.page)
      @name = sprintf('%s.xml', site.config['feed']['name'])

      self.read_yaml(File.join(base, '_layouts'), site.config['feed']['layout'])

      self.data['link_first'] = feed_path(site, 1)
      self.data['link_last'] = feed_path(site, pager.total_pages)
      self.data['link_next'] = feed_path(site, pager.page + 1) if pager.page != pager.total_pages
      self.data['link_previous'] = feed_path(site, pager.page - 1) if pager.page != 1

      self.process(@name)
    end

    def feed_path(site, page)
      sprintf('%s%s', feed_dir(site, page), @name)
    end

    def feed_dir(site, page)
      if page == 1
        "/"
      else
        sprintf(
          "/%s/%s",
          site.config['feed']['name'],
          site.config['paginate_path']
        ).sub(':num', page.to_s)
      end
    end
  end
end
