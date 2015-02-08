require 'pry'

module Jekyll
  class AtomBuilder < Generator
    safe true

    def generate(site)
      posts = site.posts.sort_by { |p| -p.date.to_f }
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

      if pager.page == 1
        @dir = "/"
        @name = "atom.xml"
      else
        @dir = "/atom"
        @name = "page#{pager.page}.xml"
      end

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "atom.xml")
    end
  end
end
