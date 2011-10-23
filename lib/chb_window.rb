require_relative 'gmvc'

class CHBView < GMVC::View
  attr :glade

  def self.glade_filename
    "chb.glade"
  end
  def self.window_name
    "chb_window"
  end
  def unhandled_signal(signal)
    puts "Unhandled signal encountered: " + signal
  end
end

class CHBModel < GMVC::Model
   
end

class CHBWindow < GMVC::Controller
  @@model = CHBModel.new    # All views will share the same model
  def initialize
    @model = @@model
  end
  def default_view_class
    CHBView
  end
  def on_mb_file_menu_quit_activate
    puts "button clicked!"
    @view.close
  end
end

window = CHBWindow.open
Gtk.main