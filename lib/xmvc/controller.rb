module XMVC
  class Controller
    attr_reader :view_names, :model
    
    # Initialize class instance variables whenever we are subclassed
    def self.inherited(subclass)
      subclass.initialize
    end
    
    # Initialize all class instance variables
    def self.initialize
      return if @initialized
      ary = self.name.split('::')
      raise "Controller class #{ary.last} is not named properly - must end in 'Controller'" if ary.last[-10..-1] != "Controller"
      @controller_class_name = ary.pop
      @view_class_name = @controller_class_name[0..-11] + 'View'
      @my_module_name = ary.join('::')
      @my_module = eval(@my_module_name)
      raise "Controller class #{@controller_class_name} is not defined in a module" if !@my_module
      @initialized = true
    end
    
    def self.my_module
      @my_module
    end
    
    def self.get_view_class(view_name)
      class_name = @view_class_name + view_name.capitalize
      file_name = XMVC::convert_to_underscores(class_name)
      self.windowing_system.require_view(file_name)
      @my_module.const_get(class_name)
    end
    
    def get_view(view_name)
      self.class.get_view_class(view_name).new(@model, self, view_name)
    end
    
    def initialize(model)
      @model = model
      @view_names = Array.new
      @views = Hash.new
      @visible = false
    end
    
    def hide
      
    end
    
    
    # Change the view, maintaining the visibility of the window
    def change_view(view_name = @model.default_view_name)
      return if @view and @view.name == view_name
      visible = @view.visible? if @view
      view_name = self.view_names.first if !view_name
      raise "View '#{view_name.to_s}' not found" if !view_name
      @view.hide if @view
      @view = @views[view_name] ||= self.get_view(view_name)
      @view.show if visible
    end
    
    # Show the current view using the supplied flags (:modal, :maximized, etc)
    def show(*flags)
      self.change_view if @view.nil?
      @view.show(*flags)
      @visible = @view.visible?
    end
  end
end