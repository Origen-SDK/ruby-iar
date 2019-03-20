module RubyIAR
  module Helpers
    require 'erb'

    class DefinesFile

      module TemplateHelpers
        def self.generate(def_or_inc)
          if def_or_inc.key?(:include)
            "#include #{def_or_inc[:include]}\n"
          elsif def_or_inc.key?(:symbol)
            "#define #{def_or_inc[:symbol]}" + (def_or_inc[:value].nil? ? '' : " #{def_or_inc[:value]}") + "\n"
          else
            fail "Unrecognized: could not find either an :include or :symbol key in 'def_or_inc' hash. Unable to generate."
          end
        end

        def self.write_define(sym, value: nil)
          "#define #{sym}" + (value.nil? ? '' : " #{value}") + "\n"
        end

        def self.write_include(inc)
          "#include #{inc}\n"
        end

        def self.header
          self.block_comment([
            "This is an auto-generated header file produced by the RubyIAR plugin.",
            "Depending on the settings of the driver, this file may be cleaned or overridden each time the build executable is run.",
            "Hand-edits to this file may not survive from run to run.",
            "Please update the driver settings to propogate updates to this file.",
          ])
        end

        def self.block_comment(comment, body_indent: 2)
          comment = [comment] if comment.is_a?(String)
          [
            "/*",
            *(comment.map { |c| "#{' ' * body_indent}#{c}" }),
            "*/"
          ].join("\n")
        end

        def self.comment(c, comment_indent: 0, body_indent: 1)
          "#{' ' * comment_indent}//#{' ' * body_indent}#{c}\n"
        end
      end

      attr_reader :driver
      attr_reader :_defines_and_includes_
      attr_reader :name
      attr_reader :output_dir

      def initialize(driver:, name: nil, output_dir: nil, build_actions: [])
        @driver = driver

        @name = name || driver.name
        self.output_dir = output_dir
        @build_actions = build_actions
        @_defines_and_includes_ = []
      end

      def output_dir=(dir)
        @output_dir = dir.nil? ? nil : Pathname(dir)
      end

      def write(options={})
        if options[:output_dir]
          out = Pathname(options[:output_dir]).join("#{name}.h")
        elsif output_dir
          out = output_dir.join("#{name}.h")
        else
          out = driver.defines_working_directory.join("#{name}.h")
        end

        e = ERB.new(File.read(Pathname(__FILE__).dirname.join('defines_file.h.erb').to_s), 0, '%<>')
        File.open(out, 'w') do |f|
          f.puts(e.result(binding))
        end
        out
      end

      def clean
        fail
      end

      def include(header, options={})
        _defines_and_includes_ << {include: header}
      end
      alias_method :include_header, :include
      alias_method :preinclude, :include
      
      def include_headers(*headers)
        _defines_and_includes_ += headers.map { |h| {include: h} }
      end
      alias_method :preinclude_headers, :include_headers

      def define(symbol, value: nil, type: :raw, args: nil)
        case type
        when :raw
          _defines_and_includes_ << {
            symbol: symbol,
            value: value,
          }
        when :function_call
          if args.nil?
            args = []
          end
          _defines_and_includes_ << {
            symbol: symbol,
            value: "do { #{value}(#{args.join(', ')}); } while(0);",
          }
        when :string
          _defines_and_includes_ << {
            symbol: symbol,
            value: "\"#{value}\"",
          }
        else
          fail "Unknown define type #{type} for symbol #{symbol}"
        end
      end
      
      def define_str(symbol, value)
        define(symbol, value: value, tpye: :string)
      end

      def define_function_call(symbol, function_name, function_args: nil)
        define(symbol, value: function_name, tpye: :function_call, args: function_args)
      end

      def define_from_hash(symbol_hash)
        fail
      end

      def define_multiple(*symbol_hash_pairs)
        fail
      end
    end

  end
end