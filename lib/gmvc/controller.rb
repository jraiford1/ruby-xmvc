require_relative 'builder'
module GMVC
  class Controller < XMVC::Controller
    attr_reader :builder
    def self.windowing_system
      GMVCApp
    end
    # By default the glade file will be the same as the class name with a .glade suffix
    def self.glade_filename
      File.join(self.glade_directory, self.name.split("::").last.downcase[0..-11] + ".glade")
    end
    def self.glade_directory
      # return @@glade_directory if @@glade_directory
      @@glade_directory ||= File.join($project_directory, 'lib/gtk2/glade')
    end
    # By default the main window name will be the same as the class name
    def self.window_name
      self.name.split("::").last.downcase
    end
    # Initialize our extra variables
    def initialize(*args)
      super
      self.load
    end
    # Load the associated glade file
    def load
      puts "Loading glade file: #{self.class.glade_filename}"
      @builder = GMVC::Builder.new
      @builder.add_from_file(self.class.glade_filename)
      
      @builder.top_windows.each do |obj|
        @view_names << obj.builder_name
      end
      
      self.connect_signals
      puts @view_names
    end
    
    def connect_signals
      @builder.connect_signals do |handler|
        if self.methods.include?(handler.to_sym)
          self.method(handler)
        else
          lambda { self.unhandled_signal(handler) }
        end
      end
    end
    
    ## TODO: Everything below here is still being reworked and may end up in other classes
    def self.open
      self.new.open
    end
    def open_view(view_class)
      @view = view_class.new(self, @model)
      self          # return self
    end
  end
end