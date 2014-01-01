require 'securerandom'
require 'open-uri'
require 'uri'

class Asset
  include Mongoid::Document
  field :url # absolute url
  field :type # image, stylesheet, javascript, etc.
  field :filename # "name.ext"
  field :size, type: Integer # bytes
  field :succeed, type: Boolean, default: true
  field :exists, type: Boolean, default: true # the url means the existence of the asset?

  index url: -1
  index type: -1

  belongs_to :site
  belongs_to :page

  before_create do |asset|
    asset.site_id = page.site_id if page
  end

  before_destroy do |asset|
    File.delete(asset.path)
  end

  class << self
    %w{image stylesheet javascript other}.each do |type|
      define_method "create_#{type}", ->(url, page = nil) do
        asset = Asset.new(url: url, type: type)
        asset.filename = Asset.randstr + (
          case type
          when 'stylesheet'
            ".css"
          when 'javascript'
            ".js"
          when 'image'
            URI.parse(url).path.downcase[/\.(jpg|png|gif|jpeg|bmp)$/] || '.jpg'
          else
            URI.parse(url).path.downcase[/\.[a-z0-9]{2,5}$/] || ''
          end
        )
        begin
          open(url){|f| File.write(asset.path, f.read)}
          asset.size = File.size(asset.path)
        rescue StandardError
          asset.succeed = false
        end
        asset.page = page
        asset.succeed = asset.save
        asset
      end
    end

    %w{stylesheet javascript}.each do |name|
      define_method "create_#{name}_code_asset", ->(content, page = nil) do
        asset = Asset.new(exists: false, type: type)
        asset.filename = Asset.randstr + ({"javascript"=>".js", "stylesheet"=>".css"}[name])
        if page
          asset.url = page.url
          asset.page = page
        end
        File.write(asset.path, content)
        asset.size = File.size(asset.path)
        asset.succeed = asset.save
        asset
      end
    end

    def randstr
      Time.now.to_i.to_s(36) + SecureRandom.hex(5)
    end
  end

  def path
    Mirror.root + "/assets/#{type}s/#{filename}"
  end
end