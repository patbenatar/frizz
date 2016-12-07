module Frizz
  class Ignorance
    attr_reader :patterns

    def initialize(patterns, prefer_gzip)
      @patterns = patterns || []
      @prefer_gzip = prefer_gzip
    end

    def ignore?(path)
      ignore_matched_pattern?(path) || ignore_for_gzip_version?(path)
    end

    private

    def ignore_matched_pattern?(path)
      return false unless patterns.count

      patterns.any? { |p| ::File.fnmatch(p, path) }
    end

    def ignore_for_gzip_version?(path)
      return false unless prefer_gzip

      return false if path.ends_with? '.gz'

      gzip_file_version_path = "#{path}.gz"
      return true if ::File.file?(gzip_file_version_path)
    end
  end
end
