require 'date'

class HackernewsController < Controller
  def daily # http://www.daemonology.net/hn-daily/2010-07-11.html
    urls = Date.parse('2010-07-11').upto(Date.today - 1).map{|d| 
      "http://www.daemonology.net/hn-daily/#{d.strftime('%Y-%m-%d')}.html"
    }
    Index.process(urls) do |page|
      if page
        hnlinks = HackerNews::Link.new
        hnlinks.page = page
        print(hnlinks.save ? '.' : '*')
      else
        print "*"
        sleep(3)
      end
    end
  end
end