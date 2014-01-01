require 'open-uri'

class Model
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  @@field_config, @@index_config = {}, {}

  # belongs_to :page

  class << self
    %w{one many}.each do |name|
      # css_one/css_many
      define_method "css_#{name}" do |hashes, &block| # cannot use yield or block_given? in define_method's block-closure
        hashes.each_pair do |key, value|
          # field key, type: (name=='one' ? String : Array)
          @@field_config[self.name] ||= {}
          @@field_config[self.name][key] = {pattern: value, block: block, array: (name == 'many')}
        end
      end
    end
    
    # the document of model is index page
    def index_page(pattern, args = [])
      @@index_config[self.name] = [pattern, args]
    end

    # rewrite collection name
    def collection_name
      "documents"
    end
  end

  # inner_one/inner_many : help to proccess node in block of css_one&css_many
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
    page = Page.fetch(url)
    self.page = page if page
  end

  def page=(page)
    config = @@field_config[self.class.name]
    document = page.document
    config.each_pair do |key, value|
      block = value[:block] || ->(node){ node.content.strip }
      if value[:array] # Nokogiri::XML::NodeSet
        val = document.css(value[:pattern]).map{|node| block.call(node)}# Node: http://nokogiri.org/Nokogiri/XML/Node.html
      else # Nokogiri::XML::Node
        val = block.call(document.css(value[:pattern]).first)
      end
      self[key] = val
    end
    # self["page"] = page
  end

  def index?
    @@index_config[self.class.name].present?
  end

  def index
    index? ? Index.new(*@@index_config[self.class.name]) : nil
  end

  def export
  end
end


class Hash
  def clear_nil
    Hash[self.reject{|_,v| v.nil?}]
  end
end