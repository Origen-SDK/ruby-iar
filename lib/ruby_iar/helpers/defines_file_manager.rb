module RubyIAR
  module Helpers
    module DefinesFileManager
      def defines_file(name=nil)
        if name
          _defines_files_[name]
        else
          active_defines_file
        end
      end

      def defines_files(name=nil)
        if name
          _defines_files_[name]
        else
          _defines_files_.keys
        end
      end

      def active_defines_file
        @active_defines_file || begin
          RubyIAR.fail(ActiveNotSetError, 'No active defines file has been set!')
        end
      end

      def defines_file=(name)
        set_defines_file(name)
      end

      def set_defines_file(name)
        @active_defines_file = _defines_files_[name] ||= begin
          #RubyIAR.fail(MissingDefinesFile, "Could not set active defines file to #{name}. Could not find that defines file!")
          _defines_files_[name] = DefinesFile.new(driver: self, name: name)
          _defines_files_[name]
        end
      end

      def _defines_files_
        @_defines_files_ ||= {}.with_indifferent_access
      end

      def defines_working_directory
        working_directory.join('define_files')
      end

    end
  end
end
