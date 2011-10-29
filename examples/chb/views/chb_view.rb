
class CHBView < GMVC::View

  def self.glade_filename
    "chb.glade"
  end
  def self.window_name
    "chb_window"
  end
  def unhandled_signal(signal)
    puts "Unhandled signal encountered: " + signal
  end
  def init_window
    super
    self.init_classes
    self.init_methods
  end
  def init_classes
    @classes = @builder.get_object("classes")
    @classes.model = @model.classes_treestore
    @classes.headers_visible = false
    @classes_renderer = Gtk::CellRendererText.new
    @classes_column = Gtk::TreeViewColumn.new("Class Name", @classes_renderer, :text => 0)
    @classes.append_column(@classes_column)
    @classes.selection.set_select_function do |selection, classes_model, path, currently_selected|
      class_iter = classes_model.get_iter(path)
      return true if class_iter.nil?
      @controller.on_class_selected(self, @methods, class_iter, currently_selected)
    end
    def methods_type
      :instance_methods
    end
  end
  
  
  def init_methods
    @methods = @builder.get_object("methods")
    # @methods.model = @model.methods_liststore
    @methods.headers_visible = false
    @methods_renderer = Gtk::CellRendererText.new
    @methods_column = Gtk::TreeViewColumn.new("Method Name", @methods_renderer, :text => 0)
    @methods.append_column(@methods_column)
  end
end