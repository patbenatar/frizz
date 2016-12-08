module Frizz
  class Site
    def initialize(host, options={})
      @options = { from: "build", :prefer_gzip: false }.merge options

      @ignorance = Ignorance.new(@options[:ignore], @options[:prefer_gzip])

      if @options[:distribution]
        @distribution = Distribution.new(@options[:distribution])
      end

      local_options = take_keys(options, [:redirect_rules])
      @local = Local.new(path_to_deploy, ignorance, local_options)

      remote_options = take_keys(options, [:region, :prefer_gzip])
      @remote = Remote.new(host, ignorance, remote_options)
    end

    def deploy!
      changes = Sync.new(local, remote).run!
      distribution.invalidate!(changes) if distribution
    end

    private

    attr_reader :local, :remote, :options, :distribution, :ignorance

    def take_keys(hash, keys_array)
      hash.select do |k, v|
        keys_array.include? k
      end
    end

    def path_to_deploy
      File.expand_path(options[:from])
    end
  end
end
