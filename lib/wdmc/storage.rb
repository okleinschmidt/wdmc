require 'wdmc'
require 'rainbow/ext/string'
require 'json'



module Wdmc
  class Storage < Thor

    option :json, aliases: '-j', type: 'boolean', banner: 'Output as JSON'

    def initialize(*args)
      @sc = Xsc::Client.new
      super
    end

    desc 'search [QUERY]', 'Search Groups'
    def shares
    end

  end
end
