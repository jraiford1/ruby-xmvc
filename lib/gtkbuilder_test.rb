require_relative 'gmvc'

class HelloView < GMVC::View
  attr :glade

  def self.glade_filename
    "test.glade"
  end
  def self.window_name
    "window1"
  end
  def unhandled_signal(signal)
    puts "Unhandled, but defined, signal encountered: " + signal
  end
end

class HelloModel < GMVC::Model
  
end

class HelloWindow < GMVC::Controller
  @@model = HelloModel.new    # All views will share the same model
  def initialize
    @model = @@model
  end
  def default_view_class
    HelloView
  end
  def on_button1_clicked
    puts "button clicked!"
    @view.hide
  end
end

hello = HelloWindow.open
hello = HelloWindow.open
hello = HelloWindow.open
Gtk.main