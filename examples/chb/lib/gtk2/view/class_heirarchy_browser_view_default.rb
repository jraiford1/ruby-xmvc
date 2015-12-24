require 'gtksourceview3'

module GMVCApp
  class ClassHeirarchyBrowserViewDefault < GMVC::View
    attr_reader :methods_list, :source_code
    attr_accessor :class_info
    def init_window
      super
      self.init_class_tree        # Class TreeView
      self.init_methods_selector  # Instance/Class Radio Buttons
      self.init_variables_list    # Instance/Class Variables ListView
      self.init_methods           # Instance/Class Methods ListView
      self.init_source_code       # Source code SourceView
    end
    def init_class_tree
      @class_tree = @builder.get_object("classes")
      classes_treestore = self.classes_treestore
      @class_tree.model = classes_treestore
      @class_tree.headers_visible = false
      @class_tree_renderer = Gtk::CellRendererText.new
      @class_tree_column = Gtk::TreeViewColumn.new("Class Name", @class_tree_renderer, :text => 1)
      @class_tree.append_column(@class_tree_column)
      @class_tree.selection.signal_connect "changed" do |selection, class_tree_model|
        @controller.class_selected(selection, class_tree_model)
      end
      @class_tree.selection.set_select_function do |selection, class_tree_model, path, currently_selected|
        @controller.about_to_select_class(selection, class_tree_model, path, currently_selected)
      end
    end
    def classes_treestore
      classes_treestore = @model['classes_treestore']
      if classes_treestore.nil?
        classes_treestore = Gtk::TreeStore.new(Object,String)
        @model.classes.root_classes.each do |root_class_info|
          self.add_class_info(classes_treestore, nil, root_class_info)
        end
        classes_treestore.set_sort_column_id(1, Gtk::SortType::ASCENDING)
        @model['classes_treestore'] = classes_treestore
      end
      classes_treestore
    end
    def add_class_info(treestore, parent, class_info)
      iter = treestore.append(parent)
      iter[0] = class_info
      iter[1] = class_info.class_name
      class_info.subclasses.each do |subclass_info|
        self.add_class_info(treestore, iter, subclass_info)
      end
    end
    def init_methods_selector
      self.methods_selector = :instance_methods
    end
    def methods_selector=(symbol)
      case symbol
      when :instance_methods
        radio_button = @builder.get_object("rb_instance")
        radio_button.active = true
      when :class_methods
        radio_button = @builder.get_object("rb_class")
        radio_button.active = true
      else
        raise ArgumentError.new("Invalid method selector '#{symbol}'")
      end
    end
    def methods_selector
      rb_instance = @builder.get_object("rb_instance")
      if rb_instance.active?
        return :instance_methods
      end
      rb_class = @builder.get_object("rb_class")
      if rb_class.active?
        return :class_methods
      end
      return nil
    end
    def init_variables_list
      @variables_list = @builder.get_object("variables")
    end
    def init_methods
      @methods_list = @builder.get_object("methods")
      @methods_list.headers_visible = false
      @methods_renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new("Method Name", @methods_renderer, :text => 1)
      @methods_list.append_column(column)
      @methods_list.selection.signal_connect "changed" do |selection, methods_model|
        @controller.method_selected(selection, methods_model)
      end
      @methods_list.selection.set_select_function do |selection, methods_model, path, currently_selected|
        @controller.about_to_select_method(selection, methods_model, path, currently_selected)
      end
    end
    def method_liststore(class_info)
      methods_liststores = @model['methods_liststores']
      if methods_liststores.nil?
        methods_liststores = {}
        @model['methods_liststores'] = methods_liststores
      end
      liststore_name = "#{class_info.class_name}.#{self.methods_selector}".to_sym
      method_liststore = methods_liststores[liststore_name]
      if method_liststore.nil?
        method_liststore = self.new_methods_liststore_for_class(class_info, self.methods_selector)
        methods_liststores[liststore_name] = method_liststore
      end
      method_liststore
    end

    def init_source_code
      @source_code = GtkSource::View.new
      @builder.get_object("source_code_sw").add(@source_code)
      @source_code.show_line_numbers = true
      font = Pango::FontDescription.new("Monospace Bold 10")
      @source_code.override_font(font)
      @source_code.insert_spaces_instead_of_tabs = true
      @source_code.indent_width = 2
      @source_code.show_right_margin = true
      @source_code.right_margin_position = 80
      language = GtkSource::LanguageManager.new.get_language('ruby')
      @source_code.buffer.language = language
      @source_code.buffer.highlight_syntax = true
      @source_code.buffer.highlight_matching_brackets = true
      @source_code.visible = true
      code_block = lambda do |value|
        buffer = @source_code.buffer
        puts buffer.undo_manager
        old-max-levels = buffer.max-undo-levels
        buffer.max-undo-levels = 0
        buffer.text = value
        buffer.max-undo-levels = old-max-levels
      end
      self.attach_widget_to_attribute(@source_code, 'source_code', code_block)
    end

    def unhandled_signal(signal)
      puts "Unhandled signal encountered: " + signal
    end


    def new_methods_liststore_for_class(class_info, methods_selector)
      liststore = Gtk::ListStore.new(Object, String)
      case methods_selector
      when :instance_methods
        methodInfoHash = class_info.inst_methods
      when :class_methods
        methodInfoHash = class_info.cls_methods
      else
        raise ArgumentError.new("Invalid method selector '#{symbol}'")
      end
      methodInfoHash.each_value do |method_info|
        iter = liststore.append
        iter[0] = method_info
        iter[1] = method_info.method_name
      end
      liststore.set_sort_column_id(1, Gtk::SortType::ASCENDING)
      liststore
    end
    def register_methods_view_for_class(view, class_iter, methods_type)
      puts "register_methods_view_for_class"
      key = class_iter[1] + '#' + methods_type.to_s
      if !@methods_liststores.include?(key)
        liststore = self.new_methods_liststore_for_class(class_iter[0], methods_type)
        @methods_liststores[key] = {liststore => []}
      end
      @methods_liststores[key].values.first << view
      view.model = @methods_liststores[key].keys.first
      true
    end
    def unregister_methods_view_for_class(view, class_iter, methods_type)
      puts "unregister_methods_view_for_class"
      key = class_iter[1] + '#' + methods_type.to_s
      return true if !@methods_liststores.include?(key)
      puts "problem" if @methods_liststores[key].values.first.delete(view).nil?
      @methods_liststores.delete(key) if @methods_liststores[key].values.first.size == 0
      view.model = nil
      true
    end
  end
end
