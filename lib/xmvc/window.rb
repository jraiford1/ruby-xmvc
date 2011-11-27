module XMVC
  class Window
    attr_reader :model, :windowing_system, :view, :views, :controller
    
    # Initialize class instance variables whenever we are subclassed
    def self.inherited(subclass)
      subclass.initialize
    end
    
    # Initialize all class instance variables
    def self.initialize
      return if @initialized
      ary = self.class.name.split('::')
      raise "Window class #{ary.last} is not named properly - must end in 'Window'" if ary.last[-6..-1] != "Window"
      @window_class_name = ary.pop
      @model_class_name = @window_class_name + 'Model'
      @controller_class_name = @window_class_name + 'Controller'
      @my_module_name = ary.join('::')
      @my_module = eval(@my_module_name)
      raise "Window class #{@window_class_name} is not defined in a module" if !@my_module
      @model_class.const_get(@model_class_name)
      @initialized = true
    end
    
    # Return the controller class for the given windowing system
    def self.controller_class(windowing_system = $application.windowing_system)
      windowing_system.const_get(@controller_class_name)
    end
    
    # Initialize the new window instance
    def initialize(model = self.class.model_class.new, windowing_system = $application.windowing_system)
      raise "Model #{model} is not a valid model" if !model.kind_of?(XMVC::Model)
      @model = model
      @windowing_system = windowing_system
      @controller = self.class.controller_class(@windowing_system).new(@model)
    end
    
    # Pass some things off to the model
    def [] element ; @model[element] ; end
    def []= element, value ; @model[element] = value ; end
    
    # Pass some things off to the controller
    def hide ; @controller.hide ; end
    def show(*args) ; @controller.show(*args) ; end
    # Return true if the window is currently visible
    def visible? ; @controller.visible? ; end
    # Set up all the needed objects and relationships, but don't display the window
    def open(*args) ; @controller.change_view(*args) ; end
    def close(*args) ; @controller.close(*args) ; end
  end
end
























































































