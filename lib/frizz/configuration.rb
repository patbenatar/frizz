module Frizz
  class Configuration
    YAML_FILENAME = "frizz.yml"

    attr_accessor :access_key_id, :secret_access_key, :environments,
      :current_environment

    def initialize
      self.environments = {}

      # Attempt to load defaults from ENV
      self.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
      self.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
      self.current_environment = ENV["FRIZZ_ENV"] || "development"

      # Allow to be overridden in yaml
      if yaml_exists?
        load_yaml!
        start_yaml_listener
      end
    end

    def environment
      environments[current_environment]
    end

    def environments=(environments_data)
      @environments = environments_data.each_with_object({}) do |(name, data), obj|
        obj[name] = Environment.new(name, data)
      end
    end

    private

    def yaml_exists?
      File.exists?(YAML_FILENAME)
    end

    def load_yaml!
      puts "== Frizz: Loading frizz.yml"

      YAML.load_file(YAML_FILENAME).each do |key, value|
        send "#{key}=", value
      end
    end

    def start_yaml_listener
      require "listen"
      listener = Listen.to Dir.pwd

      listener.change do |modified, added, removed|
        load_yaml! if modified.include? "frizz.yml"
      end

      listener.start
    end
  end
end