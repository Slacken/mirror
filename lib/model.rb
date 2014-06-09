require 'open-uri'

class Model
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  
  @@config = {}

  belongs_to :page, dependent: :delete

  %w{field index header url}.each do |name|
    define_singleton_method "#{name}_config=", ->(value){ 
      @@config[self.name].nil? ? (@@config[self.name] = {name => value}; value): (@@config[self.name][name] = value)
    }
    define_singleton_method "#{name}_config", ->{ @@config[self.name].nil? ? nil : @@config[self.name][name] }
    define_method "#{name}_config", ->{ self.class.send("#{name}_config") }
  end

  class << self
    %w{one many}.each do |name|
      # css_one/css_many
      define_method "css_#{name}" do |hashes, &block| # cannot use yield or block_given? in define_method's block-closure
        hashes.each_pair do |key, value|
          # field key, type: (name=='one' ? String : Array)
          self.field_config ||= {}
          self.field_config[key] = {pattern: value, block: block, array: (name == 'many')}
        end
      end
    end
    
    # the document of model is index page
    def index_page(pair)
      raise "Invalid arguments for index_page" unless pair.size == 1
      self.index_config = pair.first
    end

    def one_page(url)
      self.url_config = url
    end

    def set_cookie(cookie)
      cookie = cookie.instance_of?(Hash) ? cookie.map{|k,v| "#{k}=#{v}"}.join("; ") : cookie.to_s
      if self.header_config
        self.header_config["Cookie"] = cookie
      else
        self.header_config = {"Cookie" => cookie}
      end
    end

    # rewrite collection name
    def collection_name
      "documents"
    end

    def index?
      index_config.present?
    end

    def index
      index? ? Index.new(*index_config) : nil
    end

    def fetch_all!
      index.process do |page|
        m = self.new
        m.page = page
        m.save!
      end
    end

    # one page model
    def fetch!
      m = self.new
      m.fetch(url_config)
      m.save!
    end
  end

  # inner_one/inner_many : help to process node in block of css_one&css_many
  class Nokogiri::XML::Node
    %w{one many}.each do |name|
      define_method "inner_#{name}" do |css, &block| 
        block ||= ->(node){ node.text.strip }
        if name == 'one' # inner_one
          block.call(self.css(css).first)
        else # inner_many
          self.css(css).map{|node| block.call(node)}
        end
      end
    end
    alias :source :to_xml
  end

  def fetch(url)
    page = Page.fetch(url, header_config || {})
    if page
      self.page = page
    else
      raise "cannot fetch page(#{url})"
    end
  end

  def page=(page)
    document = page.document
    if document
      field_config.each_pair do |key, value|
        block = ->(node) do 
          if node
            (value[:block] || ->(n){ n.content.strip }).call(node)
          else
            nil # for un-matches
          end
        end
        if value[:array] # Nokogiri::XML::NodeSet
          val = document.css(value[:pattern]).map{|node| block.call(node)}# Node: http://nokogiri.org/Nokogiri/XML/Node.html
        else # Nokogiri::XML::Node
          val = block.call(document.css(value[:pattern]).first)
        end
        self[key] = val
      end
      self["page_id"] = page.id
    else
      raise "page no document"
    end
    page
  end

  def export
  end
end


class Hash
  def clear_nil
    Hash[self.reject{|_,v| v.nil?}]
  end
end