module RubyIAR
  class Driver
    class Workspace
      include ProjectManager

      # Create a new workspace object, but does not write it to the disk.
      # This creates an internal representation only.
      # The returned Workspace object will not have a directory path set.
      def self.new_workspace(ws, dir: nil, projects: [], write: false, overwrite: false)
        n_new_ws = Nokogiri::XML::Document.new
        n_new_ws << Nokogiri::XML::Element.new('workspace', n_new_ws)
        n_new_ws.at_xpath('workspace') << Nokogiri::XML::Element.new('batchBuild', n_new_ws)

        ws = Pathname(ws).expand_path
        ws = ws.dirname.join(Pathname(ws.basename.to_s + (ws.extname.to_s == '.eww' ? '' : '.eww')))

        # Do some error checking here
        if ws.exist?
          #RubyIAR.error([
          #  "A workspace already exists at #{ws}!",
          #  "#new_workspace shying away from create a new one.",
          #  #"Use the option overwrite: true to forcibly create a new workspace at that location, or give a different location."
          #])
          #puts "Need a case for ws exists!".red
        end
        ws = Workspace.new(ws, model_only: n_new_ws)

        unless projects.empty?
          ws.add_projects(projects)
        end
        ws
      end
      singleton_class.send(:alias_method, :create_workspace, :new_workspace)

      # Creates a new workspace object AND writes the file to the disk.
      # This returns a new Workspace object that is setup as if the workspace was previously existing.
      #def self.new_workspace_at(ws, dir: nil, projects: [])
      #end

      #include InstanceOverrideClassConfigurable
      @project_xpath = '//workspace/project'
      @ws_dir_token = '$WS_DIR$'

      attr_reader :noko
      attr_reader :_projects_
      attr_reader :driver

      def initialize(eww_file, driver: nil, **options)
        if options[:model_only]
          # Indicated that that this eww_file doesn't actually exists and that we're dealing with an internal (e.g., in memory) model.
          @noko = options[:model_only] || begin
            fail "Nokogiri model not given!"
          end

          @workspace_directory = eww_file.dirname
        elsif !File.exists?(eww_file)
          fail("RubyIAR: Workspace: Could not find given .eww #{eww_file} - Unable to initialize Workspace!")
        else
          @workspace_directory = File.dirname(eww_file)

          @noko = Nokogiri::XML(File.open(eww_file)) do |n|
            n.strict.noblanks
          end
        end
        @eww_file = Pathname(eww_file)
        @name = @eww_file.basename('.eww')

        @_projects_ = {}
        projects_with_format(:absolute_pathnames).each do |path|
          proj = RubyIAR::Driver::Project.new(path, workspace: self)
          @_projects_[proj.name] = proj
        end

        @driver = driver
      end

      def workspace_directory
        @workspace_directory
      end
      alias_method :workspace_dir, :workspace_directory
      alias_method :ws_dir, :workspace_directory
      alias_method :dir, :workspace_directory
      alias_method :directory, :workspace_directory

      def resolve_path(path)
        path = Pathname(path)
        unless path.extname == '.ewp'
          path = Pathname.new(path.to_s + '.ewp')
        end

        if path.relative?
          Pathname('$WS_DIR$').join(path)
        elsif
          # Replace the absolute path with the workspace directory token
          # E.g.: C:\my_projects\project1\p1.ewp and C:\my_projects\project1\p1.eww
          #   #=> $WS_DIR$\p1.ewp
          Pathname(path.to_s.gsub(workspace_dir.to_s, '$WS_DIR$'))
        end
      end

      # This method will accept projects as either a list of either
      # strings, symbols, Pathnames, or an Array of any of the former.
      def add_project(*projects)
        def add(p, options={})
          p = Pathname.new(p)

          # Any absolute paths here won't translate well across users.
          # Ensurethat the projects are added relative to the current workspace directory, even
          # if an absolute path is given.

          n_new_proj = noko.at_xpath('//workspace').new_node('project')
          n_new_proj << n_new_proj.new_node('path', content: resolve_path(p))
          noko.at_xpath('//workspace') << n_new_proj
          p
        end

        projects.collect do |p|
          add(p, options)
        end
      end

      def add_project!(write_options: nil, **options)
        add_project(options)
        write_eww(write_options)
      end

      def copy_project(**options)
        fail "Not implemented yet!"
      end

      # Copies the project, per {#copy_project}, and writes the .eww, per {#write_eww}.
      # @note This will update <u>ALL</u> changes in the Nokogiri model. This is not isolated to just the copy project operation.
      def copy_project!(write_options: nil, **options)
        copy_project(options)
        write_eww(write_options)
      end

      def remove_project(**options)
        fail "Not implemented yet!"
      end

      def remove_project!(write_options: nil, **options)
        remove_project(options)
        write_eww(write_options)
      end

      # List all the current projects available in the Eww.
      # @return [Array]
      def projects(proj=nil, options={})
        options = proj if proj.is_a?(Hash)
        if proj
          # Allow proj to be either a Symbol or String
          _projects_[proj.to_s]
        else
          _projects_.keys
        end
        #n_project_nodes.map { |c| c.to_s }
        #begin
        #  projects_with_format(:names_only)
        #rescue MultipleProjectError
          # Can't have the #projects method throwing this error. In this case, catch the error
          # and return the absolute paths.
        #  projects_with_format(:absolute_paths)
        #end
      end
      alias_method :projs, :projects

      def projects_with_format(format)
        case format
        when :absolute_pathnames
          # Returns the projects as absolute pathname objects
          n_project_nodes.map { |proj| Pathname.new(proj.text.gsub('$WS_DIR$', workspace_directory)) }
        when :absolute_paths
          # Returns the projects as absolute paths, represented by Strings
          n_project_nodes.map { |proj| Pathname.new(proj.text.gsub('$WS_DIR$', workspace_directory)).to_s }
        when :raw
          # Returns the projects as the raw input data from the .eww.
          n_project_nodes.map { |proj| proj.to_s }
        else
          fail "Unknown format value: #{format}"
        end
      end

      # Writes the .eww file.
      def write
        File.open(@eww_file, 'w') do |f|
          f.puts(@noko)
        end
        @eww_file
      end
      alias_method :write_eww, :write

      def refresh_eww
        fail
      end

      # Forces a refresh of Nokogiri's model of the .eww, throwing away any user changes.
      def refresh_eww!
        fail
      end

      ###

      # Grabs all of the project nodes.
      # @return [Nokogiri::XML::NodeSet]
      def n_project_nodes
        noko.xpath('//workspace/project/path').children
      end

      def n_project_node(n)
        fail "Not implemented yet!"
      end

    end
  end
end
