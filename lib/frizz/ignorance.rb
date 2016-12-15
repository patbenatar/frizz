module Frizz
  class Ignorance
    attr_reader :patterns, :prefer_gzip

    def initialize(patterns, prefer_gzip)
      @patterns = patterns || []
      @prefer_gzip = prefer_gzip
    end

    def ignore?(local_path, base_path = nil)
      ignore_matched_pattern?(local_path) || ignore_for_gzip_version?(local_path, base_path)
    end

    private

    def ignore_matched_pattern?(local_path)
      return false unless patterns.count

      patterns.any? { |p| ::File.fnmatch(p, local_path) }
    end

    def ignore_for_gzip_version?(local_path, base_path)
      return false unless base_path && prefer_gzip

      full_path = File.join(base_path, local_path)

      return false if full_path.end_with? '.gz'

      gzip_file_version_path = "#{full_path}.gz"
      return true if ::File.file?(gzip_file_version_path)
    end
  end
end
