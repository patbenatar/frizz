module Frizz
  class Site
    def initialize(host, options={})
      @options = { from: "build" }.merge options

      @ignorance = Ignorance.new(@options[:ignore])

      if @options[:distribution]
        @distribution = Distribution.new(@options[:distribution])
      end

      @local = Local.new(path_to_deploy, ignorance)
      @remote = Remote.new(host, ignorance)
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
