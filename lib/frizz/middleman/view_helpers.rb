module Frizz
  module Middleman
    module ViewHelpers
      def frizz
        Frizz.configuration.environment
      end
    end
  end
end