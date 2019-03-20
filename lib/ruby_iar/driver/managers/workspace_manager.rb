module RubyIAR
  class Driver

    # Mixin/organizational module for managing workspaces.
    module WorkspaceManager
      
      def _workspaces_
        @workspaces ||= {}
      end

      def load_workspace(eww_file)
        _workspaces_[eww_file.to_s] = RubyIAR::Driver::Workspace.new(eww_file, driver: self)
      end
      alias_method :load_eww, :load_workspace

      def workspace(workspace_name=nil)
        if workspace_name
          _workspaces_[workspace_name]
        else
          active_workspace
        end
      end
      alias_method :ws, :workspace

      def workspaces(workspace_name=nil)
        fail
      end

      def active_workspace
        @active_workspace || begin
          fail "No active workspaces set!"
        end
      end

      def workspace_root
        active_workspace.root
      end
      alias_method :eww_root, :workspace_root

    end
  end
end
