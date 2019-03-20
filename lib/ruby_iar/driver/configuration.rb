module RubyIAR
  class Driver
    class Configuration

      attr_reader :name
      attr_reader :node
      attr_reader :ewp
      attr_reader :project

      def initialize(node:, project:)
        @node = node
        @project = project
        @name = node.at_xpath('name').text
      end

      ### Some shortcut methods are provided for commonly used options/settings.

      def shortcut
      end

      # General -> Target -> Core
      def core
      end

      # General -> Target -> Device
      def device
      end

      # General -> Library Configuration -> Use CMSIS
      def use_cmsis
      end

      # General -> Library Configuration -> Use CMSIS (true/false)
      def use_cmsis?
      end

      # General -> Output -> Executable/Libraries
      # General -> Output -> Object Files
      # General -> Output -> List Files

      # Runtime Checking -> C/C++ Compiler
      # Runtime Checking -> C/C++ Compiler -> Language 1 -> Language
      # Runtime Checking -> C/C++ Compiler -> Optimizations -> Level
      # Runtime Checking -> C/C++ Compiler -> Output -> Generate Debug Information
      # Runtime Checking -> C/C++ Compiler -> Output -> Code Section Name
      # Runtime Checking -> C/C++ Compiler -> List -> Output List File
      # Runtime Checking -> C/C++ Compiler -> List -> Output List File -> Assembler Mnemonics
      # Runtime Checking -> C/C++ Compiler -> List -> Output List File -> Diagnostics
      # Runtime Checking -> C/C++ Compiler -> List -> Output Assembler File
      # Runtime Checking -> C/C++ Compiler -> List -> Output Assembler File -> Include Source
      # Runtime Checking -> C/C++ Compiler -> List -> Output Assembler File -> Include Call Frame Information
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Ignore Standard Include Directories
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Additional Include Directories
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Preinclude File
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Defined Symbols
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Preprocessor Output To File
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Preprocessor Output To File -> Preserver Comments
      # Runtime Checking -> C/C++ Compiler -> Preprocessor -> Preprocessor Output To File -> Generate #line Directives

      # Runtime Checking -> Assembler
      # Runtime Checking -> Assembler -> Language
      # Runtime Checking -> Assembler -> Language -> User Symbols are Case Sensitive
      # Runtime Checking -> Assembler -> Output -> Generate Debug Information
      # Runtime Checking -> Assembler -> Preprocessor -> Ignore Standard Include Directories
      # Runtime Checking -> Assembler -> Preprocessor -> Additional Include Directories
      # Runtime Checking -> Assembler -> Preprocessor -> Defined Symbols

      # Runtime Checking -> Output Converter
      # Runtime Checking -> Output Converter -> Generate Additional Output
      # Runtime Checking -> Output Converter -> Output Format
      # Runtime Checking -> Output Converter -> Override Default
      # Runtime Checking -> Output Converter -> Override Default (filename)

      # Runtime Checking -> Custom Build

      # Runtime Checking -> Build Actions

      # Runtime Checking -> Linker

      # Defines the symbols for the C/C++ preprocessor, the assembler, and the linker.
      def define_symbol(symbol, value=nil, only_for: nil) # , raw_symbol: false)
        #fail "Needs implementing!"
        if value
          d = "#{symbol}=#{value}"
        else
          d = symbol
        end
        n_get_option_node('CCDefines', setting: 'ICCARM').add_state(d, type: :array)
        #n_get_option_node('ADefines', setting: 'AARM').add_state(d, type: :array)
        #n_get_option_node('IlinkDefines', setting: 'ILINK').add_state(d, type: :array)
      end

      def defined_symbols
        retn = {}
        retn[:compiler] = n_get_option_node('CCDefines', setting: 'ICCARM').state(type: :array)
        retn[:assembler] = n_get_option_node('ADefines', setting: 'AARM').state(type: :array)
        retn[:linker] = n_get_option_node('IlinkDefines', setting: 'ILINK').state(type: :array)
        retn
      end

      # Allows definition of multiple symbols at once from an Hash.
      # Potentially, the symbol_hash could be read out of a JSON or XML file.
      def define_symbols_from_hash(symbol_hash, only_for: nil)
        fail "Needs implementing!"
      end

      # Adds additional 'include' directories to the C/C++ compiler and Assembler tools.
      # @note The linker setup does not have an option to add additional include directories.
      # This allows directories to be either:
      #   A single String
      #   A single Pathname
      #   An array of Strings/Pathnames
      #   A mix of the above three
      def add_include_directories(*directories, only_for: nil)
        dirs = directories.collect do |d|
          if d.is_a?(String)
            [d]
          elsif d.is_a?(Pathname)
            [d.to_s]
          elsif d.is_a?(Array)
            d.map { |_d| _d.to_s }
          else
            fail "Cannot process directory type: #{d.class}"
          end
        end.flatten

        # Todo: add state should accept an array.
        dirs.each do |d|
          n_get_option_node('CCIncludePath2', setting: 'ICCARM').add_state(d, type: :array)
          n_get_option_node('Includes', setting: 'AARM').add_state(d, type: :array)
        end
        #get_option_node('', setting: 'ILINK')

      end

      def output_directory
        Pathname(project.ws.workspace_directory).join(n_get_option_node('ExePath', setting: 'General').state.first)
      end

      'IlinkAdditionalLibs'
      'IlinkConfigDefines'
      'IlinkOverrideProgramEntryLabel' # type: :checkbox
      'IlinkProgramEntryLabelSelect' # type: radio
      'IlinkProgramEntryLabel'
      'IlinkIcfOverride' # type: :checkbox
      'IlinkIcfFile'

      ### These methods are used to get arbitrary categories/settings and options in the .ewp

      def setting(s)
      end
      alias_method :category, :setting

      def settings(s=nil)
      end
      alias_method :categories, :settings

      def [](category)
      end

      # Config manipulation

      # Creates a new config in the same project using this config as a base.
      # This will keep everything the same except for the name and output directories.
      def copy_to(new_name, preserve: false)
        # :preserve can either be a symbol, an array of symbols, or a blanket true/false.
        # Handle each possiblity here.
        def preserve?(setting)
          if preserve.is_a?(Array)
            preserve.include?(setting)
          elsif preserve.is_a?(Symbol)
            preserve == setting
          elsif preserve == true
            true
          elsif preserve == false
            false
          else
            fail "Unrecongized preserve option #{preserve} of class: #{preserve.class}"
          end
        end

        # Adjust the output directories of the new config.
        # This something IAR will do automatically, so we'll do it here as well.
        #def adjust_output_dirs(n_new_config)
        #end

        n_new_config =  node.dup.unlink
        n_new_config.at_xpath('name').content = new_name
        node.parent << n_new_config

        new_config = Config.new(node: n_new_config, project: project)
        project._configs_[new_config.name] = new_config

        # Other than the name, change a few other things, like output directories.
        new_config.reset_output_dirs unless preserve?(:output_dirs)
        new_config
      end

      def reset_output_dirs
        n_get_option_node('ExePath', setting: 'General').update_state("#{name}\\Exe", type: :string)
        n_get_option_node('ObjPath', setting: 'General').update_state("#{name}\\Obj", type: :string)
        n_get_option_node('ListPath', setting: 'General').update_state("#{name}\\List", type: :string)
      end

      ### These methods return nokogiri node options

      def n_get_setting_node(setting)
        node.get_setting_node(setting)
      end

      def n_get_option_node(option, setting:)
        n_get_setting_node(setting).get_option_node(option)
      end

      def driver
        project.ws.driver
      end

      def make!
        driver.make_config!(self, project: project)
      end

      def build!
        driver.build_config!(self, project: project)
      end
    end

  end
end
