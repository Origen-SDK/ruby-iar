module RubyIAR
  class Driver

    # Mixin/organizational module for managing projects within a workspace.
    module ProjectManager

      def load_ewp(ewp_file)
        #@workspace_manager = workspace_manager
        #@ewp_file = ewp_file
        #@ewp = load_ewp(ewp_file)

        project = RubyIAR::Driver::Project.new(ewp_file)
        project.load_configurations
        project
      end

      def active_project
        @active_project || begin
          fail "No active project has been set!"
        end
      end
      alias_method :current_project, :active_project

      # @raise [MultipleProjectError]
      def active_project=(proj)
        set_active_project(proj)
      end
      alias_method :project=, :active_project=
      alias_method :proj=, :active_project=
      alias_method :active_proj=, :active_project=
      alias_method :current_project=, :active_project=
      alias_method :current_proj=, :active_project=

      def set_active_project(proj, options={})
        @active_project = project(proj) || begin
          fail "Cannot set active project to #{proj} - Could not find such project."
        end
      end

      # Indicates whether the project exists in the .eww.
      # @note This doesn't check whether or not the actual project exists, just whether or not the particular
      #   project is enumerated in the .eww.
      def project?(p)
        projects.include?(p)
      end
      alias_method :proj?, :project?

      def project(proj=nil)
        if proj
          projects(proj)
        else
          active_project
        end
      end
      alias_method :proj, :project

    end
  end
end
