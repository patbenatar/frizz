module Frizz
  class NullEnvironment
    # Don't raise on undefined methods. Allows for flexible use of frizz.yml
    # attributes.
    def method_missing(meth, *args, &block); end
  end
end
