module RubyIAR
  require_relative './driver/configuration'
  require_relative './driver/managers/configuration_manager'
  require_relative './driver/project'
  require_relative './driver/managers/project_manager'
  require_relative './driver/workspace'
  require_relative './driver/managers/workspace_manager'

  require_relative './toolchain'
  require_relative './helpers/defines_file_manager'
  require_relative './helpers/defines_file'

  class Driver
    include WorkspaceManager
    include RubyIAR::Helpers::DefinesFileManager

    attr_reader :name

    def initialize(name: nil, dir: nil, verify_on_instantiation: false, workspace: nil)
      #@defines_file = RubyIar::Helpers::DefinesFile.new(driver: self)

      @iar_installation = RubyIAR::Toolchain::Installation.new(name: name, dir: dir)
      if verify_on_instantiation
        @iar_installation.verify
      end

      # If a workspace is given, open it up and create a workspace a manager.
      if workspace.is_a?(Array)
        fail "Todo: Multiple workspaces aren't yet supported!"
      else
        @active_workspace = load_workspace(workspace)
      end

      @name = name.to_s || 'ruby_iar'
    end

    def backup_directory
      working_directory.join(backup_dir_suffix)
    end

    def log_directory
      working_directory.join(log_dir_suffix)
    end

    def working_dir_suffix
      name
    end

    # Points to RubyIAR's local workspace directory, used for creating backup files,
    # storing log files, writing the defines files, and general caching.
    def working_directory
      Pathname(workspace.dir).join(working_dir_suffix)
    end
    alias_method :working_dir, :working_directory

    # Some shortcut methods to run the IAR utilities.
    
    # Builds the given project and configuration. If one or neither are missing, the active ones are used.
    def build!(projects: nil, configs: nil)
      if projects.is_a?(Array)
        fail "Not supported yet!"
      elsif projects.is_a?(String) || projects.is_a?(Symbol) || projects.is_a?(Pathname)
        fail "Not supported yet! (2)"
      elsif projects.is_a?(RubyIAR::Driver::Project)
        iar_build.build(project_ewp: projects.ewp_file, configs: configs)
      else
        iar_build.build(projects: project, configs: config)
      end
    end

    # Given a String or Symbol of project name, or the projects themselves, returns the projects.
    # This is just a utility method to provide a common iterface for getting the projects from various inputs.
    def _resolve_projects_(projects)
      if projects.is_a?(Array)
        projects.collect { |p| _resolve_projects_[p] }
      elsif projects.is_a?(String)
        [ws._projects_[projects]]
      elsif projects.is_a?(Symbol)
        [ws._projects_[projects.to_s]]
      elsif projects.is_a?(RubyIAR::Driver::Project)
        [ws._projects_.value?(projects) ? projects : false]
      else
        puts "Cannot resolve project from given type #{projects.class}.".red
        RubyIAR.runtime_error([
          "Cannot resolve project from given type #{projects.class}.",
          "Please only use Strings, Symbols. or EWP objects, or an Array of the aforementioned types."
        ])
      end
    end

    # Same as #_resolve_projects_, except raises and exception if the given project is not found.
    def _resolve_projects_!(projects)
      missing = []
      projs = _resolve_projects_(projects).each_with_index do |p, i|
        if p.nil?
          missing << projects[i]
        end
      end
      unless missing.empty?
        raise MissingProjectException, projs
      end
      projs
    end

    # Builds everything. This will run #bulld! for all the projects in the workspace, and runs each project with
    # all configs selected.
    # If a project is given, only the configs from that project will be built instead.
    def build_all!(projects: nil)
      fail
    end

    # Builds the project given in proj.
    # If no project is given, the active project will be instead.
    # If options are given and contians :configs, only those configs will be built.
    # Othwrise, all configs will be built.
    def build_project!(project=nil, options={})
      p = project.nil? ? self.project : self._resolve_projects_!(project)
      build!(projects: p, configs: options[:configs])
    end

    # Builds the config for the current project.
    # If no config is given, the active config on the active project is used.
    # @note This requires that an active project be set.
    def build_config!(config=nil, options={})
      p = options[:project] ? self._resolve_projects_!(options[:project]).first : self.project
      #config = p.config(config)
      build!(projects: p, configs: config.name)
    end

    def make!
      fail
    end

    # Cleans the current build directory
    def clean!
      fail
    end

    def iar_installation
      @iar_installation
    end
    alias_method :iarinstallation, :iar_installation
    alias_method :iar_install, :iar_installation
    alias_method :iarinstall, :iar_installation

    def iarbuild
      iar_installation.iar_build
    end
    alias_method :iar_build, :iarbuild
  end
end