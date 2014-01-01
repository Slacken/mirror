require 'net/http'
require 'net/https'
require 'uri'

class Request
  class << self
    def get(url, get_params = {}, header = {})
      request(url,get_params,'get', header)
    end
   
    def post(url, post_params = {}, header = {})
      request(url,post_params,'post', header)
    end
   
    def request(url,request_params,method = 'get',header)
      header.merge!({
        "User-Agent" => "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      })
      uri = URI(url)
      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = (uri.scheme == 'https')
      if method == 'get'
        header["Content-Type"] = "text/html; charset=utf-8"
        path = (uri.path.length > 0 ? uri.path : '/')
        if uri.query.nil?
          query = (request_params.empty? ? "" : ("?" + URI.encode_www_form(request_params)))
        else
          query = "?#{uri.query}" + (request_params.empty? ? "" : ("&" + URI.encode_www_form(request_params)))
        end
        response = http.get(path + query, header)
      else
        header["Content-Type"] = "application/x-www-form-urlencoded"
        response = http.post(uri.path + (uri.query.nil? ? "" : "?#{uri.query}") ,URI.encode_www_form(request_params), header)
      end
      if response.kind_of? Net::HTTPSuccess
        response.body  # data = JSON.parse(response.body)
      else
        Mirror.logger.error(response.inspect)
        nil
      end
    end

    def full_url(url,current_url)
      uri = URI.parse(current_url)
      base = uri.scheme+"://"+uri.host
      return url if (url.start_with?("http") || url.start_with?(uri.scheme))
      return base+url if url.start_with?("/")
      path = uri.path[/\S*\//] # the URI lib's path seems not fits well
      base + path + url
    end

    def clean_url(url)
      url.split('#').first
    end

    def interval(seconds)
      loop do
        if block_given?
          yield 
        else
          break
        end
        sleep(seconds)
      end
    end
  end

end