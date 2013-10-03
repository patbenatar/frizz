module Frizz
  module Middleman
    module ViewHelpers
      def frizz
        @frizz ||= EnvironmentDecorator.new(Frizz.configuration)
      end

      class EnvironmentDecorator
        attr_accessor :config

        def initialize(config)
          @config = config
          define_environment_helpers!
        end

        def method_missing(meth, *args, &block)
          config.environment.send(meth) # pass thru to environment attrs
        end

        private

        def define_environment_helpers!
          config.environments.each do |name, env|
            self.class.send :define_method, "#{env.name}?" do
              env == config.environment
            end
          end
        end
      end
    end
  end
end