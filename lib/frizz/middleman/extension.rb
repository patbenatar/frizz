require "frizz/middleman/view_helpers"

module Frizz
  module Middleman
    class Extension < ::Middleman::Extension
      self.defined_helpers = [Frizz::Middleman::ViewHelpers]

      def initialize(app, options_hash={}, &block)
        super
      end
    end
  end
end

::Middleman::Extensions.register(:frizz, Frizz::Middleman::Extension)
