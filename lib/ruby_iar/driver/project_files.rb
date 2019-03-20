module RubyIAR
  class Driver

    class ProjectFileGroup
      attr_reader :name
      attr_reader :files
      attr_reader :groups
      attr_reader :heiarchy
      attr_reader :parent
      attr_reader :node
      attr_reader :project

      def initialize(project:, node:)
        @project = project
        @node = node

        _name_!
        _groups_!
        _files_!
      end

      def _name_!
        @name = n_name.content
      end

      def _groups_!
        @groups = n_groups.collect do |n_group|
          g = ProjectFileGroup.new(project: project, node: n_group)
          [g.name, g]
        end.to_h
      end

      def _files_!
        @files = n_files.collect do |n_file|
          f = ProjectFile.new(project: project, node: n_file)
          [f.name, f]
        end.to_h
      end

      def to_h
        {
          name => {
            groups: begin
              retn = {}
              @groups.each { |n, g| retn.merge!(g.to_h) }
              retn
            end,
            files: @files.collect { |n, f| n },
          }
        }
      end

      def xpath
      end

      def parent_xpath
      end

      def add_group(name, files: [], active_configs: [], inactive_configs: [])
        n_newgrp = node.new_node('group')
        n_newgrp << n_newgrp.new_node('name')
        n_newgrp.at_xpath('name').content = name
        node << n_newgrp
        
        #files.each { |f| n_newgrp.add_file(f, active_configs: active_configs, inactive_configs: inactive_configs) }
        #_groups_!
        #_groups_[name].apply_inactive_configs(active_configs: active_configs, inactive_configs: inactive_configs)
        #_groups_[name]

        newgrp = ProjectFileGroup.new(project: self.project, node: n_newgrp)
        @groups[newgrp.name] = newgrp

        newgrp.add_files(files)
        newgrp.apply_config_exclusions(active_configs: active_configs, inactive_configs: inactive_configs)
        newgrp
      end

      def add_files(*files, active_configs: [], inactive_configs: [])
        def add(f, active_configs: active_configs, inactive_configs: inactive_configs)
          n_new_file = node.new_node('file')
          n_new_file << n_new_file.new_node('name')
          n_new_file.at_xpath('name').content = f
          node << n_new_file

          new_file = ProjectFile.new(project: self.project, node: n_new_file)
          @files[new_file.name] = new_file
          new_file.apply_config_exclusions(active_configs: active_configs, inactive_configs: inactive_configs)
          new_file
        end

        new_files = []
        files.each do |f|
          if f.is_a?(Array)
            new_files += f.map { |_f| add(_f, active_configs: active_configs, inactive_configs: inactive_configs) }
          else
            new_files << add(f, active_configs: active_configs, inactive_configs: inactive_configs)
          end
        end
        #_files_!
        new_files
      end
      alias_method :add_file, :add_files

      def apply_config_exclusions(active_configs: [], inactive_configs: [])
        def exclude_config(c)
          node.at_xpath('excluded') << node.at_xpath('excluded').new_node('configuration', content: c)
        end
        
        if !active_configs.empty? && !inactive_configs.empty?
          fail "Both active configs and inactive configs cannot be provided! Please provide one or the other."
        end

        if !node.at_xpath('excluded')
          node << node.new_node('excluded')
        end

        if active_configs.empty?
          # No active configs provided, apply the inactive configs directly.
          inactive_configs.each { |c| exclude_config(c) }
        else
          # Active configs given. Apply the inactive configs to all available configs except the ones listed.
          (project.configs - active_configs).each { |c| exclude_config(c) }
        end
      end

      def remove_group(name)
        fail
      end

      def remove_file(file, group: nil)
        fail
      end

      def update!
        fail
      end

      def n_groups
        node.xpath('group')
      end

      def n_files
        node.xpath('file')
      end

      def n_name
        node.at_xpath('name')
      end
    end

    class ProjectFile
      attr_reader :node
      attr_reader :project
      attr_reader :name

      def initialize(project:, node:)
        @project = project
        @node = node

        _name_!
      end

      def to_h
        { name => name }
      end

      def _name_!
        @name = n_name.content
      end

      def n_name
        node.at_xpath('name')
      end

      def apply_config_exclusions(active_configs: [], inactive_configs: [])
        def exclude_config(c)
          node.at_xpath('excluded') << node.at_xpath('excluded').new_node('configuration', content: c)
        end
        
        if !active_configs.empty? && !inactive_configs.empty?
          fail "Both active configs and inactive configs cannot be provided! Please provide one or the other."
        end

        if !node.at_xpath('excluded')
          node << node.new_node('excluded')
        end

        if active_configs.empty?
          # No active configs provided, apply the inactive configs directly.
          inactive_configs.each { |c| exclude_config(c) }
        else
          # Active configs given. Apply the inactive configs to all available configs except the ones listed.
          (project.configs - active_configs).each { |c| exclude_config(c) }
        end
      end
    end

    class ProjectFiles < ProjectFileGroup
      
      def initialize(project:)
        #@project = project
        super(project: project, node: project.noko)
        @node = project.noko.at_xpath('//project')

        #@groups = n_groups.collect do |g|
        #  n = g.at_xpath('name').content
        #  [n, FileGroup.new(name: n, project: self, node: g)]
        #end.to_h

        #@files = n_files.collect do |f|
        #  n = g.at_xpath('name').content
        #  [n, File.new(name: n, project: self, node: f)]
        #end.to_h
      end

      def _name_!
        @name = 'Top'
      end

      def activate_group_for_config(group: nil, groups: [], config: nil, configs: [])
        fail
      end
      alias_method :activate_groups_for_config, :activate_group_for_config
      alias_method :activate_group_for_configs, :activate_group_for_config
      alias_method :activate_groups_for_configs, :activate_group_for_config
      alias_method :enable_group_for_config, :activate_group_for_config
      alias_method :enable_group_for_configs, :activate_group_for_config
      alias_method :enable_groups_for_config, :activate_group_for_config
      alias_method :enable_groups_for_configs, :activate_group_for_config
      alias_method :activate_group, :activate_group_for_config
      alias_method :activate_groups, :activate_group_for_config
      alias_method :enable_group, :activate_group_for_config
      alias_method :enable_groups, :activate_group_for_config

      def deactivate_group_for_config(group: nil, groups: [], config: nil, configs: [])
        fail
      end

      def n_groups
        project.noko.xpath('//project/group')
      end

      def n_files
        project.noko.xpath('//project/file')
      end
    end

  end
end
