require 'set'
require 'gtk2'

module GMVC
  class View
    @@all_views = Set.new
    @@visible_windows = 0
    attr_accessor :controller, :builder, :window, :modal
    
    def initialize(controller, model)
      @@all_views.add(self)
      @controller = controller
      @model = model
      self.load_from_file(self.class.glade_filename)
      
      @builder = Gtk::Builder::new
      self.create_objects
      @window = @builder.get_object(self.class.window_name)
      self.connect_signals
      @window.hide
      self.init_window
      @model.register_view(self) if !@model.nil?
      self.show
    end
    def create_objects
      @builder.add_from_file(self.class.glade_filename)
    end
    def connect_signals
      @builder.connect_signals do |handler|
        if self.methods.include?(handler.to_sym)
          self.method(handler)
        elsif @controller.methods.include?(handler.to_sym)
          @controller.method(handler)
        else
          lambda { self.unhandled_signal(handler) }
        end
      end
      @window.signal_connect('destroy') { self.on_destroy }
      @window.signal_connect('delete_event') { self.on_delete_event }
    end
    def unhandled_signal(signal)
    end
    def self.default_visibility
      false
    end
    def show(visible = true)
      return visible if @window.visible? == visible
      if visible == true
        @window.show
        @@visible_windows += 1
      else
        @@visible_windows -= 1
        @window.hide
        Gtk.main_quit() if @@visible_windows <= 0
      end
    end
    def hide
      self.show(false)
    end
    def init_window
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
      return if @@all_views.delete?(self).nil?   # just in case 
      @@visible_windows -= 1
      @model.unregister_view(self) if !@model.nil?
      Gtk.main_quit() if (@@visible_windows <= 0) or (@@all_views.size == 0)
    end
  end
end