require 'rubygems'
require 'bundler'

Bundler.require

%w{lib models}.each do |dir|
  Dir[File.expand_path("../../#{dir}/*.rb",__FILE__)].each {|file| require file }
end

require 'logger'

module Mirror
  def self.root
    File.expand_path('../../',__FILE__)
  end

  def self.logger
    @@logger ||= Logger.new(root + "/tmp/log.log") # or Logger.new('logfile.log') # STDOUT
  end
end

Mongoid.load!(File.expand_path('../../config/mongoid.yml',__FILE__), :default)