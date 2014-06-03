module Frizz
  class Ignorance
    attr_reader :patterns

    def initialize(patterns)
      @patterns = patterns || []
    end

    def ignore?(path)
      return false unless patterns.count
      patterns.any? { |p| ::File.fnmatch(p, path) }
    end
  end
end
