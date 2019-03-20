module RubyIAR
  class Driver
    class Project
      require_relative './project_files'
      
      @configurations_xpath = '//project/configuration'
      @extract_config_nodes = Proc.new do |noko|
      end

      attr_reader :noko
      attr_reader :name
      attr_reader :ewp_file
      attr_reader :_configs_
      attr_reader :_project_files_
      
      def initialize(ewp_file, options={})
        unless File.exists?(ewp_file)
          fail("RubyIAR: EWP: Could not find given .ewp #{ewp_file} - Unable to initialize EWP!")
        end
        @workspace = options[:workspace]
        @name = ewp_file.basename('.ewp').to_s
        @ewp_file = ewp_file
        #@workspace_directory = File.dirname(eww_file)

        @noko = Nokogiri::XML(File.open(ewp_file)) do |n|
          n.strict.noblanks
        end

        @_configs_ = extract_config_nodes
        @_project_files_ = ProjectFiles.new(project: self)
      end

      def project_files
        @_project_files_
      end

      def workspace
        @workspace
      end
      alias_method :ws, :workspace

      def configs(config=nil, options={})
        options = config if config.is_a?(Hash)
        if config
          _configs_[config.to_s]
        else
          _configs_.keys
        end
      end

      def config(_config=nil)
        if _config
          configs(_config)
        else
          active_config
        end
      end

      def active_config
        @active_config ||= begin
          fail "No active/current config has been set!"
        end
      end
      alias_method :current_config, :active_config
      
      def active_config=(_config)
        set_active_config(_config)
      end

      def set_active_config(_config, options={})
        @active_config = self.config(_config) || begin
          fail "Cannot set active/current configuration to #{_config} - Could not find such configuration."
        end
      end
      alias_method :set_current_config, :set_active_config

      # Load the configurations.
      def load_configurations
        @_configs_ = extract_config_nodes
      end

      def write(output_name: nil, output_dir: nil, appendage: nil, tmp: false)
        filename = (output_dir.nil? ? ewp_file.dirname : Pathname.new(output_dir)).expand_path
        filename = filename + (output_name || ewp_file.basename)

        if appendage
          filename = filename.dirname.join(Pathname.new(filename.basename(filename.extname).to_s + "_#{appendage}" + filename.extname))
        end

        if filename.extname != '.ewp'
          filename = Pathname.new(filename.to_s + '.ewp')
        end
        
        if tmp
          filename = Pathname.new(filename.to_s + '.tmp')
        end

        write_to(filename)
      end

      def write_to(output_filename)
        File.open(output_filename, 'w') do |out|
          out.puts(noko)
        end

        output_filename
      end

      # Returns a hash with the name of the config as the key and the config object as the value.
      def extract_config_nodes
        nodes = @noko.xpath('//project/configuration')

        # Although IAR won't let you create a config with the same name, we are, after all, screwing with the project XML.
        # RubyIAR will also not let you add duplicate configs, but since it also provides some methods to run arbitrary XML, add
        # some protection against multiple configs.
        # Print warnings in this case. Things won't work as expected, but at least let the user know there's a problem.
        #nodes.map do |n|
        #  n.at_xpath('name')
        #  [name, n]
        #end.to_h
        nodes.each_with_object(Hash.new) do |node, hash|
          c = RubyIAR::Driver::Configuration.new(node: node, project: self)
          if hash.key?(c.name)
            puts "ERROR! A confguration #{c.name} is already present in the .ewp! Appending the object ID #{c.object_id} to the name, but this will NOT work as expected in IAR. Please correct the .ewp"
            hash["#{c.name}_#{c.object_id}"] = c
          else
            hash[c.name] = c
          end
        end
      end

      def configurations
      end

    end
  end
end
