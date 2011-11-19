module XMVC
  # This assumes:
  # * A single module (optional)
  # * A single class
  class RubyFile
    attr_accessor :file_name, :rf_requires, :rf_require_relatives
    attr_accessor :rf_module, :rf_module_name, :rf_module_methods, :rf_module_instance_methods
    attr_accessor :rf_class, :rf_class_name, :rf_superclass_name, :rf_class_methods, :rf_class_instance_methods
    
    def initialize
      @rf_requires = Array.new
      @rf_require_relatives = Array.new
      @rf_module_methods = Array.new
      @rf_module_instance_methods = Array.new
      @rf_class_methods = Array.new
      @rf_class_instance_methods = Array.new
    end
    
    # Populate the instance based on the given file.  Return true if successful and false otherwise.
    def load_from_file(file_name)
      @file_name = file_name
      return false if !File.exist?(@file_name)
      require(@file_name)
      File.open(file_name) do | file |
        file.each do | line |
          parts = line.strip.split(' ')
          if parts
            case parts.first
            when 'require'
              @rf_requires.push(parts[1].gsub(/\A['"]|['"]\Z/, ''))
            when 'require_relative'
              @rf_require_relatives.push(parts[1].gsub(/\A['"]|['"]\Z/, ''))
            when 'module'
              @rf_module_name = parts[1]
              @rf_module = eval(@rf_module_name)
            when 'class'
              @rf_class_name = parts[1]
              @rf_class = eval(@rf_class_name)
            end
          end
        end
      end
      if @rf_module
        @rf_module_methods = @rf_module.methods(false)
        @rf_module_instance_methods = @rf_module.instance_methods(false)
      end
      if @rf_class
        @rf_class_methods = @rf_class.methods(false)
        @rf_class_instance_methods = @rf_class.instance_methods(false)
      end
      true
    end
    # Destroy the existing file if it exists and write out the skeleton
    def create_file
      File.open(@file_name, "w") do | file |
        @rf_requires.each { | req | file.puts "require '#{req}'" }
        @rf_require_relatives.each { | req | file.puts "require_relative '#{req}'" }
        file.puts ''
        file.puts "module #{@rf_module_name}" if @rf_module_name
        if @rf_class_name
          if @rf_superclass_name
            file.puts "  class #{@rf_class_name} < #{@rf_superclass_name}"
          else
            file.puts "  class #{@rf_class_name}"
          end
          file.puts "  end"
        end
        file.puts "end" if @rf_module_name
      end
    end
  end
end
