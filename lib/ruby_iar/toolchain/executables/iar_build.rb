module RubyIAR
  module Toolchain
    module Executables
      require_relative './base'

    # Handles verifying the iarbuild executable, building the command line
    #  arguments, calling/running, and finally parsing output, and finally
    #  returning status information
    class IarBuild < Base
      def initialize(install:, **options)
        @executable_name = 'iarbuild'
        @installation_offset = Pathname('common/bin')
        super(install: install, executable: executable_name)
      end

      # Runs the iarbuild utility.
      # @param project [String] The IAR project location (.ewp).
      # @param configs [String,Array] The configurations to run. Must
      #  be defined in the EWP. The '*' string denotes to run all available
      #  configurations (default)
      def run(project, configs: '*', log_level: :all, action: 'build')
      end

      #def verify
      #  puts "NEED TO VERIFY THE INSTALL"
      #end

      #def verify_executable
      #  puts "DO VERIFY EXEC"
      #end

      def show
        puts "Showing the setup for #{parent.name}'s iarbuild utility:"
        puts "  Executable: "
        puts "  Installation Offset: "
        puts "  Installation Dir: "
        puts "    (Path) => "
        puts "  Configs: NOT SET!"
        puts "  Project: NOT SET!"
        puts "    => Build Command: ?"
      end

    # Run the IAR Build utility and returns the path to the s-record, or nil if the build failed.
    # Attempts to catch some common errors as well, including:
    #   IarBuild utility not found.
    #   Project file not found
    #   Configuration not found
    #   Up-to-date Build (files not changed)
    #   Up-to-date Build but no s-record
    #   Build failed
    #   Build timeout
    def build(project_ewp:, configs:, quiet: false, debug: false)
      # Build the cmd string
=begin      if @session.get_session_variable(:iar_executable_path).nil? || @session.get_session_variable(:iar_executable_path).strip == ""
        cmd_str = "IarBuild #{ewp_file} -build #{config_name}"
      elsif (@session.get_session_variable(:iar_executable_path))[-1] == "/"
        cmd_str = "\"#{@session.get_session_variable(:iar_executable_path)}IarBuild.exe\" #{ewp_file} -build #{config_name}"
      elsif (@session.get_session_variable(:iar_executable_path))[-1] == "\\"
        cmd_str = "\"#{@session.get_session_variable(:iar_executable_path)}IarBuild.exe\" #{ewp_file} -build #{config_name}"
      else
        cmd_str = "\"#{@session.get_session_variable(:iar_executable_path)}/IarBuild.exe\" #{ewp_file} -build #{config_name}"
      end
      #cmd_str = "IarBuild #{ewp_file} -build #{config_name}"
=end
      # Verify the IAR version on the system.
      # Since IAR only works on Windows, use 'where'
      
      #! verify_executable
      
      # Constructs & runs the command.
      def cmd_for!(cmd, configs: nil, project_ewp:)
        # If no configs were given, all configs will be run.
        # Otherwise, either use the configs directly (if its a string), or join the configuration names together.
        configs = configs.nil? ? '*' : (
          !configs.is_a?(Array) ? configs : (
            !configs.empty? ? configs.join(',') : (
              fail("Configurations cannot be empty! This must be either a String listing the configs directly or nil (which runs all configurations)")
            )
          )
        )

        case cmd
        when :build, :rebuild
          puts "Beginning IAR Build Tool..."

          cmd = "#{@executable_name} #{project_ewp} -build #{configs}"
        else
          fail "Cannot construct command for :#{cmd}"
        end

        #puts "COMMAND: #{cmd}".green

        # Run the command
        def run_cmd(cmd, options={})
          begin
            stdout, stderr, status = Open3.capture3(cmd)
          rescue Errno::ENOENT => e
            puts "Captured stderr output.".red
            puts e.message
            puts e.class
            raise e
          end

          unless stderr.empty?
            #IarCompiler.to_console("=================================", type: :error)
            #IarCompiler.to_console("Found content in 'stderr' pipe:", type: :error)
            #IarCompiler.to_console("Please review the below content:", type: :error)
            puts "Encountered output in stderr:"
            puts stderr.red
            #IarCompiler.to_console("=================================", type: :error)
            #debug_logfile.puts "Errors from STDERR:"
            #debug_logfile.puts stderr
            #debug_logfile.puts "---"
            #debug_logfile.puts ""
          end
          stdout
        end
        run_cmd(cmd)
      end

      # Construct and run the build command.
      cmd_result = cmd_for!(:build, project_ewp: project_ewp, configs: configs)

=begin
      debug_logfile.puts "IAR Build CMD String: "
      debug_logfile.puts cmd_str
      debug_logfile.puts "---"
      debug_logfile.puts
=end
      # Display the path of the current build utility.
=begin
      if @session.get_session_variable(:iar_executable_path).nil? || @session.get_session_variable(:iar_executable_path).strip == ""
        IarPatgen.to_console("IarBuild is globally defined. Using IarBuild executable located at: ", type: :info)
        begin
          stdout, stderr, status = Open3.capture3("where IarBuild")
          IarPatgen.to_console(stdout, type: :info)
        rescue Errno::ENOENT => e
          puts "Rescue!"
          puts e.message
          puts e.class
          raise e
        end
      else
        IarPatgen.to_console("Using a custom IarBuild executable at:", type: :info)
        IarPatgen.to_console("#{@session.get_session_variable(:iar_executable_path)}", type: :info)
      end
=end
=begin
      # Run the cmd to get a srecord
      begin
        IarPatgen.to_console("Beginning IAR Build Tool...", type: :info)
        stdout, stderr, status = Open3.capture3(cmd_str)
      rescue Errno::ENOENT => e
        puts "Rescue!"
        puts e.message
        puts e.class
        raise e
      end
=end
      # Process the build result. We'll look for the following:
      #   1. Anything in stderr.
      #   2. ...
      # @note The build utility itself doesn't actually know, or care, about what's *actually* in the .ewp.
      #       The .ewp can throw the results wherever it wants. Its the job of the configuration manager and the
      #       driver to work out the actual output.
      #       Here, we'll just return an object that's processed all the output. Provided, the utility ran at all,
      #       providing output and context to the user will be handled by the driver.

      def process_output(result, options={})
        parse_make_output(result)
      end
      r = process_output(cmd_result)
      if r.build_passed?
        r
      else
        #IarCompiler.to_console("Compilation of IAR project has failed. Please review the IarBuild output for details.", type: :error)
        #iar_build_failed
        r
      end

=begin
      # Make sure that stderr is blank. If not, print it out.
      unless stderr.empty?
        IarCompiler.to_console("=================================", type: :error)
        IarCompiler.to_console("Found content in 'stderr' pipe:", type: :error)
        IarCompiler.to_console("Please review the below content:", type: :error)
        puts stderr.red
        IarCompiler.to_console("=================================", type: :error)
        debug_logfile.puts "Errors from STDERR:"
        debug_logfile.puts stderr
        debug_logfile.puts "---"
        debug_logfile.puts ""
      end
=end
      # Parse and output stdout results
      #puts stdout.green
=begin
      iar_logfile.puts(stdout)
      make_passed = parse_make_output(stdout)
      unless make_passed
        IarCompiler.to_console("Compilation of IAR project has failed. Please review the IarBuild output for details.", type: :error)
        iar_build_failed
      end
=end
=begin
      # Confirm that the srecord is there (even if compilation is successful, options can cause it to be renamed or
      # to not be outputted.
      # There should be a new directory in the .ewp path now with the config name.
      # Inside of that directory/Exe should be the srecord (.srec)
      unless Dir.exists?("#{project_path}/#{config_name}")
        IarCompiler.to_console("Compilation seems to have succeeded but cannot find the output folder: ", type: :error)
        IarCompiler.to_console("#{project_path}/#{config_name}", type: :error)
        IarCompiler.to_console("Please review the project options and make sure that the output is not being routed " + \
                               "to a different output folder. If it is, please change it back to the default.", type: :error)
        iar_build_failed
      end
      unless Dir.exists?("#{project_path}/#{config_name}/Exe")
        IarCompiler.to_console("Compilation seems to have succeeded but cannot find the output folder: ", type: :error)
        IarCompiler.to_console("#{project_path}/#{config_name}/Exe", type: :error)
        IarCompiler.to_console("Please review the project options and make sure that IAR is setup to generate the correct output", type: :error)
        iar_build_failed
      end
      unless File.exists?("#{project_path}/#{config_name}/Exe/#{project_name}_origen.srec")
        if File.exists?("#{project_path}/#{config_name}/Exe/#{project_name}.out")
          IarCompiler.to_console("Could not find the srecord after completing the build, but did find a .out file.", type: :error)
          IarCompiler.to_console("It looks like the build completed successfully just did not geneate a srecord.", type: :error)
          IarCompiler.to_console("Please review your #{config_name} config in IAR and " + \
                                 "check that you have instructed IAR to generate an srecord for that config", type: :error)
          IarCompiler.to_console("To check this, go to options => Output Converter (under Runtime Checking) => Ouput " + \
                                 "and check that the 'Generate additional output' is checked and that the output format " + \
                                 "is set to 'Motorola'", type: :error)
          IarCompiler.to_console("Please see the website for additional details.", type: :error)
          iar_build_failed
        else
          IarCompiler.to_console("Compilation seems to have succeeded but IarCompiler cannot find any output EXE files.", type: :error)
          IarCompiler.to_console("Please review this folder and check for the .srec and .out output files:", type: :error)
          IarCompiler.to_console("#{project_path}/#{config_name}/Exe", type: :error)
          IarCompiler.to_console("Most likely cause here is that the compilation actually failed but IarCompiler failed to " + \
                                 "recognize this and assumed the compilation passed.", type: :error)
          IarCompiler.to_console("Please review the output from IarBuild and confirm that it failed then please email a " + \
                                 "developer to report the problem. Please see the 'contact' page on the website for " + \
                                 "the developers' emails.", type: :error)
          iar_build_failed
        end
      end


      # Print some additional info to the pattern
      cc "***************************************************************************"
      cc "IAR Config:"
      cc "    IAR Version:          #{iarbuild_version || 'Failed to get extract IAR version details'}"
      cc "    IAR Project Path:     #{@parameters[:iar_project_path]}"
      cc "    IAR Project Name:     #{@parameters[:iar_project_name]}"
      cc "    IAR Project Config:   #{@parameters[:iar_configuration_name]}"
      cc "***************************************************************************"

      # Close the log files.
      IarPatgen.to_console("Iar Build Completed Successfully!".green, type: :info)
      IarPatgen.to_console("Log files available at:".green, type: :info)
      IarPatgen.to_console("#{@iar_log_dir}".green, type: :info)
      iar_logfile.close
      debug_logfile.close

      # Return the srecord file path
      "#{project_path}/#{config_name}/Exe/#{project_name}_origen.srec"
=end
    end

    # Parses the output
    # @note IAR can change what the output looks like with any version at any time. To give a bit of flexibility,
    #   several aspects of this method are derived from various class-level :attr_accessors, thus allowing users to
    #   hack at the log parsing for either debug or for a quick band-aid.
    def parse_make_output(make_str, options={})
      out = make_str.split("\n")
      result = RubyIAR::Toolchain::IarBuildReturn.new

      # Potential for output here to change as new IAR versions are released.
      # Just run the following as normal, but catch any exceptions and, if caught, display them with directions on submitting a ticket
      # before exiting.
      begin
        ## Remove the last 3 lines (empty line, total errors, total warnings)
        #total_errors = out[-2]
        #total_warnings = out[-1]
        #out = out[0..-3]

        # Ignore the first and fourth lines (these are empty) and the third line (copy right stuff).
        # But, print the next line. This contains the build version stuff.
        #puts out[1]
        if out[1].include?("Build Utility V")
          pre, sep, @iar_version = out[1].partition("Build Utility V")
          puts "Using IAR Build Utility: #{@iar_version}"
        else
          puts "Could not extract IarBuild version!".red
          puts "If you are using a newer version of IAR please open a ticket in JIRA or contact a developer.".red
          exit!
        end

        # Generally, the last line will start with ERROR for general toolchain errors and the line before it will not be empty
        if out[-1].strip.start_with?("ERROR") && !out[-2].empty?
          #IarPatgen.to_console("IAR System Error Occurred:", type: :error)
          out = out[4..-1]
          out.each do |l|
            puts l.red
          end
          on_origen_shutdown
          exit!
        end

        #out = out[5..-3]
        #num_errors = (total_errors.split(":")[1]).strip.to_i
        #num_warnings = (total_warnings.split(":")[1]).strip.to_i

        # Find the total number of errors and warnings
        # Different versions of IAR have slightly different output
        error_line = out.rindex { |l| l.include? "Total number of errors" }
        if error_line.nil?
          puts "Could not find 'total error' line in IarBuild output".red
          #IarPatgen.to_console("", type: :error)
          #IarPatgen.submit_ticket_dialog
          #IarPatgen.to_console("", type: :error)

          puts "The following is the output received from the IAR build utility.".red
          #IarPatgen.to_console("Please submit this along with the bug report.", type: :error)
          puts "BEGIN IAR BUILD OUTPUT".red
          puts make_str.red # .split("\n"))
          puts "END IAR BUILD OUTPUT".red
          exit!
        end
        total_errors = out[error_line]
        num_errors = (total_errors.split(":")[1]).strip.to_i

        # Check that the line before is an empty line
        unless out[error_line - 1].empty?
          puts "Expected line before 'total errors' to be empty.".red
          #IarPatgen.to_console("", type: :error)
          #IarPatgen.submit_ticket_dialog
          #IarPatgen.to_console("", type: :error)

          puts "The following is the output received from the IAR build utility."
          #IarPatgen.to_console("Please submit this along with the bug report.", type: :error)
          puts "BEGIN IAR BUILD OUTPUT".red
          #debug_display_output(make_str.split("\n"))
          puts make_str.red
          puts "END IAR BUILD OUTPUT".red
          #on_origen_shutdown
          exit!
        end

        # Get the total number of warnings
        total_warnings = out[error_line + 1]
        num_warnings = (total_warnings.split(":")[1]).strip.to_i

        # Now, remove the reminder of the output. This should be just empty lines and filler stuff
        out = out[0..(error_line - 1)]

        if num_errors > 0
          puts "IAR Project Compilation Failed.".red
          puts ""
          out.each_with_index do |l, i|
            if l.include?(": Warning[")
              puts "#{l}".yellow
            elsif l.include?(": Fatal Error[")
              puts "#{l}".red
            elsif l.include?(": Error[")
              puts "#{l}".red
            elsif l.start_with?("Error[")
              # Error from the linker
              puts "#{l}".red
            elsif l.start_with?("Fatal Error[")
              # Fatal error from the error
              puts "#{l}".red
            else
              puts "#{l}"
            end
          end
          puts total_errors.red
        else
          puts total_errors.green
        end
        if num_warnings > 0
          puts total_warnings.yellow
        else
          puts total_warnings.green
        end
        if num_errors > 0
          result.build_succeeded = false
          return result
        else
          result.build_succeeded = true
          return result
        end
      rescue Exception => e
        puts "Exception: #{e.class}"
        puts e.message
        #puts e
        #IarPatgen.to_console("Exceptions encountered while trying to parse the output from IarBuild utility.", type: :error)
        #IarPatgen.to_console("The most likely cause is a new IAR error was encountered or that a new version of the IarBuild utility was used.", type: :error)
        #IarPatgen.to_console("", type: :error)
        #IarPatgen.submit_ticket_dialog
        #IarPatgen.to_console("", type: :error)

        #IarPatgen.to_console("The following is the output received from the IAR build utility.", type: :error)
        #IarPatgen.to_console("Please submit this along with the bug report.", type: :error)
        #IarPatgen.to_console("BEGIN IAR BUILD OUTPUT", type: :error)
        #debug_display_output(make_str.split("\n"))
        #IarPatgen.to_console("END IAR BUILD OUTPUT", type: :error)
        #IarPatgen.to_console("", type: :error)

        #IarPatgen.to_console("The following is the exception and stack trace from Ruby.", type: :error)
        #IarPatgen.to_console("Please submit this along with the bug report.", type: :error)
        #IarPatgen.to_console("BEGIN RUBY OUTPUT", type: :error)
        #puts e
        puts e.backtrace
        #IarPatgen.to_console("END RUBY OUTPUT", type: :error)
        exit
      end
    end

      #end
    end
    IARBuild = IarBuild

  end
  end
end