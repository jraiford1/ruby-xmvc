module GMVC
  class View < XMVC::View
    attr_reader :builder
    def initialize(*args)
      super
      @attached_widgets = Hash.new
      @builder = @controller.builder
      @gtk_window = @builder.get_object(@name)
      @builder.attach_to_object(@gtk_window, self)
      @controller.connect_signals
      @gtk_window.signal_connect('delete_event') { self.on_delete_event }
      @gtk_window.signal_connect('destroy') { self.on_destroy }
    end
    def show(*flags)
      flags = [:show] if flags.empty?
      flags.each do |flag|
        case flag
        when :show
          @gtk_window.show
        end
      end
    end
    def detach_widgets_from_attributes
      @attached_widgets.each_key do |object, attribute|
        @model.set_attribute_reaction(attribute, object)
      end
    end
    def attach_widget_to_attribute(widget, attribute, assignment_method)
      object = @builder.get_object(widget)
      return nil if !object
      @model.set_attribute_reaction(attribute, object) { |value| object.method(assignment_method).call(value) }
      @attached_widgets[[object, attribute]] = assignment_method
      object
    end
    
    def about_to_close
      puts "about_to_close"
      true # return true if its ok to close the window
    end
    
    def close
      return if !self.about_to_close
      @window.destroy
    end
    
    def on_delete_event
      puts "on_delete_event"
      !self.about_to_close
    end
    
    def on_destroy
      self.detach_widgets_from_attributes
      puts "on_destroy"
    end
  end
end