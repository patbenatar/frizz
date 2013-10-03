require "cloudfront-invalidator"

module Frizz
  class Distribution
    def initialize(id)
      @id = id
    end

    def invalidate!(keys)
      return unless keys.any?
      puts "Invalidating distribution cache for: #{keys}".blue

      # $stdout.sync = true
      print "This can take a while".blue
      invalidator.invalidate(keys) do |status, time|
        case status
        when "InProgress"
          print ".".blue
        when "Complete"
          puts "#{status} in #{time}".green
        end
      end
    end

    private

    attr_reader :id

    def invalidator
      @invalidator ||= CloudfrontInvalidator.new(
        Frizz.configuration.access_key_id,
        Frizz.configuration.secret_access_key,
        id
      )
    end
  end
end