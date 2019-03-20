module RubyIAR
  class Driver
    module ConfigurationManager

      def active_configuration
        @active_config || begin
          fail "No active configuration has been set!"
        end
      end
      alias_method :current_configuration, :active_configuration
      alias_method :active_config, :active_configuration
      alias_method :current_config, :active_configuration

      # @raise [MultipleProjectError]
      def active_configuration=(config)
        set_active_configuration(config)
      end
      alias_method :configuration=, :active_configuration=
      alias_method :config=, :active_configuration=
      alias_method :active_config=, :active_configuration=
      alias_method :current_configuration=, :active_configuration=
      alias_method :current_config=, :active_configuration=

      def set_active_configuration(config, options={})
        @active_configuration = configuration(config) || begin
          fail "Cannot set active configuration to #{config} - Could not find such configuration."
        end
      end

    end
  end
end
