module Frizz
  class Site
    def initialize(host, options={})
      @options = { from: "build" }.merge options

      @local = Local.new(path_to_deploy)
      @remote = Remote.new(host)

      if @options[:distribution]
        @distribution = Distribution.new(@options[:distribution])
      end
    end

    def deploy!
      changes = Sync.new(local, remote).run!
      distribution.invalidate!(changes) if distribution
    end

    private

    attr_reader :local, :remote, :options, :distribution

    def path_to_deploy
      File.expand_path(options[:from])
    end
  end
end