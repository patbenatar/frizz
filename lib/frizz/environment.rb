module Frizz
  class Environment
    attr_reader :name, :bucket

    def initialize(name, data)
      @name = name

      data.each do |attribute, value|
        ivar_name = "@#{attribute}"
        instance_variable_set(ivar_name, value)

        self.class.send :define_method, attribute do
          instance_variable_get(ivar_name)
        end
      end

      @bucket ||= @host
    end

    # Don't raise on undefined methods. Allows for flexible use of frizz.yml
    # attributes.
    def method_missing(meth, *args, &block); end
  end
end