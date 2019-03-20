module RubyIAR
  module Toolchain

    # Represents a single IAR installation. All utility commands and executables For
    # a single IAR instance will need to be from the same installation to avoid mixing executable
    # in the event of multiple IAR installations (which is very common in corporate settings).
    class Installation
      require_relative './executables/iar_build'
      require_relative './executables/iar_ide'

      # Its possible to want to run something (e.g. regressions) from several IAR versions or
      # from several IAR projects. To simplify a bit, some defaults can be
      # given but can be overridden when multiple builders are needed.

      attr_reader :name
      attr_reader :dir
      attr_reader :version

      def initialize(name: nil, dir: :system)
        @name = name
        @dir = dir
      end

      # Verifies that the installation exists and that the iarbuild utility can be found.
      # Checks:
      #   1. The root path exists
      #   2. The 'bin' path exists.
      #   3. The iarbuild and iaridepm executables are found
      #   4. The iar_build executable can be run
      #def verify
      #  puts "FILL THIS OUT!".red
      #  iar_build.verify
      #end

      def version!
        fail
      end

      def valid?
        fail
      end

      # Builds a command
      def cmd(cmd, options={})
        fail
      end

      # Builds and runs the command, returning the output to the caller
      def cmd!(cmd, options={})
        fail
      end

      # Creates an instance of an <code>IarBuild</code> based on this particular installation.
      def iar_build
        @iar_build ||= RubyIAR::Toolchain::Executables::IarBuild.new(install: dir, parent: self)
      end
      alias_method :iarbuild, :iar_build

      # Creates an instance of an <code>IarIDE</code> based on this particular installation.
      def iar_ide
        @iar_ide_pm ||= RubyIAR::Toolchain::Executables::IarIde.new(name: name, dir: dir)
      end
      alias_method :iaride, :iar_build
    end
    #IARInstall = IarInstall
    #IARInstallation = IarInstall
    #IarInstallation = IarInstall

  end
end