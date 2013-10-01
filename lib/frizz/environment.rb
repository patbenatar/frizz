module Frizz
  class Environment
    attr_reader :name

    def initialize(name, data)
      @name = name

      data.each do |attribute, value|
        ivar_name = "@#{attribute}"
        instance_variable_set(ivar_name, value)

        self.class.send :define_method, attribute do
          instance_variable_get(ivar_name)
        end
      end
    end

    # This is a creative way to allow for calling frizz.production? or
    # frizz.staging? from the Middleman view helpers
    def method_missing(meth, args, &block)
      name == meth.to_s
    end
  end
end