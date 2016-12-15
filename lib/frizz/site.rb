module Frizz
  class Site
    def initialize(host, options={})
      @options = { from: "build", prefer_gzip: false }.merge options

      @local_ignorance = Ignorance.new(@options[:ignore], @options[:prefer_gzip])
      # for remote files, you don't need to ignore for gzip preference,
      # since there won't be any gzip files on s3
      @remote_ignorance = Ignorance.new(@options[:ignore], false)

      if @options[:distribution]
        @distribution = Distribution.new(@options[:distribution])
      end

      local_options = take_keys(options, [:redirect_rules, :prefer_gzip])
      @local = Local.new(path_to_deploy, local_ignorance, local_options)

      remote_options = take_keys(options, [:region])
      @remote = Remote.new(host, remote_ignorance, remote_options)
    end

    def deploy!
      changes = Sync.new(local, remote).run!
      distribution.invalidate!(changes) if distribution
    end

    private

    attr_reader :local, :remote, :options, :distribution, :local_ignorance,
                :remote_ignorance

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
