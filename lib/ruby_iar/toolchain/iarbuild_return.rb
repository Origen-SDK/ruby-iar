module RubyIAR
  module Toolchain
    class IarBuildReturn
      attr_reader :errors
      attr_reader :warnings
      attr_reader :messages
      
      attr_reader :output
      attr_reader :command
      attr_reader :passed

      attr_accessor :build_succeeded
      
      def initialize()
      end

      def cmd
        fail
      end

      def all_errors
        fail
      end

      def preprocessor_errors?
        fail
      end

      def compiler_errors?
        fail
      end

      def linker_errors?
        fail
      end

      def undetermined_errors?
        fail
      end

      def errors?
        fail
      end

      def warnings?
        fail
      end

      def messages?
        fail
      end

      def output
        fail
      end
      alias_method :text, :output

      def passed?
        build_succeeded
      end
      alias_method :build_passed?, :passed?

      def failed?
        !!build_succeeded
      end
      alias_method :build_failed?, :failed?

      def log
        fail
      end
      alias_method :log_file, :log

      def build_succeeded?
        build_succeeded
      end
    end
  end
end