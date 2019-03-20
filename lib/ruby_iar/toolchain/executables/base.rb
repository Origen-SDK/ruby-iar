module RubyIAR
  module Toolchain
  module Executables
    require_relative '../iarbuild_return'

    # @abstract version!
    class Base
      attr_reader :install
      attr_reader :executable_name
      attr_reader :installation_offset

      def initialize(install:, executable:, **options)
        @install = install
        @executable = ''
        #@version = version!

        # Check the subclass for any inheritance issues
      end

      #def version
      #  @version ||= version!
      #end

      #def version!
        #puts "FAIL"
        #exit!
        #"TODO".red
      #end
    end

  end
  end
end
