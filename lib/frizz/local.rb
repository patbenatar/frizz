module Frizz
  class Local
    def initialize(root_path, ignorance)
      @root_path = root_path
      @ignorance = ignorance
    end

    def files
      @files ||= begin
        Dir.chdir(root_path) do
          Dir["**/*"].map do |local_path|
            File.new(expand_path(local_path), local_path) unless ignore?(local_path)
          end.compact
        end
      end
    end

    def file_for(local_path)
      ::File.read expand_path(local_path)
    end

    private

    attr_reader :root_path, :ignorance

    def expand_path(local_path)
      ::File.join root_path, local_path
    end

    def ignore?(path)
      ::File.directory?(path) || ignorance.ignore?(path)
    end

    class File
      attr_reader :path, :key

      def initialize(path, key)
        @path = path
        @key = key
      end

      def checksum
        Digest::MD5.file(path)
      end
    end
  end
end
