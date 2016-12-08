module Frizz
  class Local
    def initialize(root_path, ignorance, options = {})
      @root_path = root_path
      @ignorance = ignorance
      @options = options
    end

    def files
      @files ||= begin
        Dir.chdir(root_path) do
          Dir["**/*"].map do |local_path|
            File.new(expand_path(local_path), local_path) unless ignore?(local_path)
          end.compact
        end
      end.concat(redirect_files)
    end

    def file_for(local_path)
      if is_redirect?(local_path)
        Tempfile.new(local_path.gsub(/\.|\//, '-'))
      else
        ::File.read expand_path(local_path)
      end
    end

    private

    attr_reader :root_path, :ignorance, :options

    def expand_path(local_path)
      ::File.join root_path, local_path
    end

    def ignore?(path)
      ::File.directory?(path) || ignorance.ignore?(path)
    end

    def is_redirect?(path)
      redirect_files.any? { |r| r.key == path }
    end

    def redirect_files
      @redirect_files ||= if options[:redirect_rules]
        options[:redirect_rules].map do |redirect_rule|
          File.new(
            expand_path(redirect_rule['from']),
            redirect_rule['from'],
            redirect_to: redirect_rule['to']
          )
        end
      else
        []
      end
    end

    class File
      attr_reader :path, :key

      def initialize(path, key, options = {})
        @path = path
        @key = key
        @options = options
      end

      def checksum
        return nil if options[:redirect_to]
        Digest::MD5.file(path)
      end

      def upload_options
        options
      end

      private

      attr_reader :options
    end
  end
end
