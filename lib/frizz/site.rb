module Frizz
  class Site
    def initialize(bucket_name)
      @local = Frizz::Local.new(path_to_deploy)
      @remote = Frizz::Remote.new(bucket_name)
    end

    def deploy!
      Frizz::Sync.new(local, remote).run!
    end

    private

    attr_reader :local, :remote

    def path_to_deploy
      File.expand_path("build")
    end
  end
end