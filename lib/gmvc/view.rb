module GMVC
  class View < XMVC::View
    attr_reader :builder
    def initialize(*args)
      super
      @builder = @controller.builder
      @gtk_window = @builder.get_object(@name)
      @controller.attach_to_object(@gtk_window, self)
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
      
      puts "on_destroy"
    end
  end
end