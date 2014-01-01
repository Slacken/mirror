require 'yaml'

class Factor
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  class << self
    def site_config
      @@site_config ||= YAML.load( File.open(Mirror.root+"/config/sites.yml") )
    end
    
    def collection_name
      "documents"
    end
  end
end