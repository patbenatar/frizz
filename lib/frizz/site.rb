module Frizz
  class Site
    def initialize(host, options={})
      @options = { from: "build" }.merge options

      @ignorance = Ignorance.new(@options[:ignore], @options[:prefer_gzip])

      if @options[:distribution]
        @distribution = Distribution.new(@options[:distribution])
      end

      local_options = options.select { |k, v| k == :redirect_rules }
      @local = Local.new(path_to_deploy, ignorance, local_options)

      remote_options = options.select do |k, v|
        k == :region || k == :prefer_gzip
      end
      @remote = Remote.new(host, ignorance, remote_options)
    end

    def deploy!
      changes = Sync.new(local, remote).run!
      distribution.invalidate!(changes) if distribution
    end

    private

    attr_reader :local, :remote, :options, :distribution, :ignorance

    def path_to_deploy
      File.expand_path(options[:from])
    end
  end
end
