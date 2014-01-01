# provide API to process page index

# String pattern : url with * to specify parmas
# Array args : counter part of * in the pattern
class Index < Struct.new(:pattern, :args)
  
  class NoBlockError < ArgumentError; end

  @@cocurrence = 20

  def self.process(urls, &block)
    raise NoBlockError, "No block given" unless block
    urls.each_slice(@@cocurrence) do |group|
      threads = []
      group.each do |url|
        threads << Thread.new(url) do |uri|
          begin
            page = Page.fetch(uri)
            block.call(page)
          rescue StandardError => e
            Mirror.logger.error(e.message + "(#{uri})")
            sleep(3)
          end
        end
      end
      threads.each{|thread| thread.join}
    end
  end

  def process(&block)
    Index.process(urls, &block)
  end

  def urls
    @urls ||= begin
      args = self.args.map{|a| (a.instance_of? Range) ? a.to_a : [a]}
      args.shift.product(*args).map{|arg| pattern_applied_url(arg)}
    end
  end

  def pattern_applied_url(arg)
    pattern.gsub('*').each_with_index{|_, i| arg[i]}
  end

end