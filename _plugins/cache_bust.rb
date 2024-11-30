require 'debug'
module CacheBust
  class CacheDigester
    require 'digest/md5'

    attr_accessor :path, :file_name

    def initialize(file_name:, source:)
      self.file_name = file_name
      self.path = File.join(source, file_name)
    end

    def digest
      [file_name, '?v=', Digest::MD5.hexdigest(file_content)[0..8]].join
    end

    def file_content
      File.read(path)
    end
  end

  def bust_cache(file_name)
    CacheDigester.new(file_name: file_name, source: @context.registers[:site].source).digest
  end
end

Liquid::Template.register_filter(CacheBust)
