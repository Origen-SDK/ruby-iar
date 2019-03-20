# Add some helper methods onto Nokogiri's elements.
module Nokogiri
  module XML
    class Document
      def new_node(name, content: content)
        n = Nokogiri::XML::Node.new(name, self)
        if content
          n.content = content
        end
        n
      end
    end

    class Element
      def get_option_node(option_name)
        opts = self.xpath("data/option")
        o_index = nil
        o_names = []
        
        opts.each_with_index do |o, i|
          o_name = o.at_xpath("name").content
          if o_name == option_name
            o_index = i
          end
          o_names << o_name
        end
        
        opts[o_index]
      end
      alias_method :get_options_node, :get_option_node
      
      def get_settings_node(setting_name)
        settings = self.xpath("settings")
        s_index = nil
        s_names = []
        
        settings.each_with_index do |s, i|
          s_name = s.at_xpath("name").content
          if s_name == setting_name
            s_index = i
          end
          s_names << s_name
        end
        
        settings[s_index]
      end
      alias_method :get_setting_node, :get_settings_node
      
      def state(type: nil)
        self.xpath('state').children.map { |c| c.text }
      end

      def set!(value)
        self.at_xpath('state').content = value
      end

      def new_node(name, content: nil)
        n = Nokogiri::XML::Node.new(name, self)
        if content
          n.content = content
        end
        n
      end

      def add_node_to(name, context, content: nil)
        context << new_node(name, content: content)
        context
      end

      def add_state(content, context)
        add_node_to('state', self, content: content)
      end

      def update_state(content, type: nil)
        # First, if the 'state' tag doesn't exists, add it.
        #if self.xpath('state').content.empty?
        #  add_node_to('state', self)
        #end

        case type
        when :array
          # In the case of an array, each each item of the array as an individual 'state' element.
          if content.is_a?(Array)
            content.each { |c| update_state(c, type: type) }
          else
            add_node_to('state', self.at_xpath('state'), content: content)
          end
        else
          fail "Cannot update state of type: #{type}"
        end
      end
    end
  end
end
