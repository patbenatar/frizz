module Frizz
  class Site
    def initialize(bucket_name, options={})
      @options = { from: "build" }.merge options
      @local = Frizz::Local.new(path_to_deploy)
      @remote = Frizz::Remote.new(bucket_name)
    end

    def deploy!
      Frizz::Sync.new(local, remote).run!
    end

    private

    attr_reader :local, :remote, :options

    def path_to_deploy
      File.expand_path(options[:from])
    end
  end
end