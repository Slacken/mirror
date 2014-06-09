require 'uri'

class Site
  include Mongoid::Document
  field :host
  field :encoding
  field :depth, type: Integer
  field :frequence, type: Integer # 1 day
  field :header, type: Hash, default: {} # {"Cookie" => "aspsky=username=slacken&usercookies=3&userhidden=2&password=2d5f11a7c2c27bac&userid=430472&useranony=;"}
  
  has_many :assets
  has_many :pages

  def self.default(url)
    find_or_create_by(host: URI(url).host)
  end

  def cookie=(cookie)
    self.header["Cookie"] = cookie.instance_of?(Hash) ? cookie.map{|k,v| "#{k}=#{v}"}.join("; ") : cookie.to_s
  end

end