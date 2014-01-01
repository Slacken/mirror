require 'uri'

class Site
  include Mongoid::Document
  field :host
  field :encoding
  field :depth, type: Integer
  field :frequence, type: Integer # 1 day

  has_many :assets
  has_many :pages
  has_many :indexes

  def self.default(url)
    find_or_create_by(host: URI(url).host)
  end

end