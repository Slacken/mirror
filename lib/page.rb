class Page
  include Mongoid::Document
  include Mongoid::Timestamps::Created # timestamp

  field :url
  # field :container, type: Hash, default: {} # url(included in content) => text
  field :title
  field :content # html

  has_many :assets
  
  index url: -1

  belongs_to :site

  attr_accessor :document

  def links
    container.keys
  end

  alias :_document :document
  def document
    _document || (self.document = Nokogiri::HTML(content) if content)
  end

  def self.fetch(url, header = {}, site = nil, options = {assets: false})
    url = Request.clean_url(url)
    page = Page.where(url: url).first
    unless page
      site ||= Site.default(url)
      page = Page.new(url: url, site: site)
      page.fetch_html!(header)
      if options[:assets]
        page.fetch_assets
      end
    end
    page
  end

  def fetch_html!(header = {})
    content = Request.get(url, {}, header)
    if content
      self.content = content
      self.document = Nokogiri::HTML(content)
      # self.container = Hash[
      #   self.document.css("body a")\
      #   .reject{|ele| ele['href'].nil? || ele['href'].downcase.start_with?('javascript:')}\
      #   .each{|ele| [Request.full_url(ele["href"], url), ele.content]}
      # ]
      self.title = self.document.title
      self.save!
    end
  end

  def fetch_assets
  end

  # not neccessary, these code are included in the content
  %w{style script}.each do |name|
    define_method "save_page_#{name}" do
      content = document.css(name).map{|ele| ele.content}.join('\n/*saved from page*/\n')
      Asset.send("create_#{{"style"=>"stylesheet", "script"=>"javascript"}[name]}_code_asset", content, self)
    end
  end
end