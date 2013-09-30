require "frizz/version"
require "colorize"

module Frizz
  autoload :Site, "frizz/site"
  autoload :Local, "frizz/local"
  autoload :Remote, "frizz/remote"
  autoload :Sync, "frizz/sync"

  Configuration = Struct.new(:access_key_id, :secret_access_key)

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end