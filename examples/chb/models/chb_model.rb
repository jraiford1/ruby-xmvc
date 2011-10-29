
class CHBModel < GMVC::Model
  attr_reader :classes_treestore, :methods_liststores
  def initialize
    super
    @methods_liststores = {}
    self.init_classes_treestore
  end
  def init_classes_treestore
    @classes_treestore = Gtk::TreeStore.new(String)
    @classes = {nil => Hash.new}
    ObjectSpace.each_object(Class) { |cls| self.store_class(cls) }
    self.load_treestore_from_hash(@classes_treestore, nil, @classes[nil]) {|iter, cls| iter[0] = cls.name } 
    @classes_treestore.set_sort_column_id(0)
  end
  
  def load_treestore_from_hash(treestore, parent, hsh, &proc)
    hsh.each do |key, value|
      iter = treestore.append(parent)
      proc.call(iter, key)
      self.load_treestore_from_hash(treestore, iter, value, &proc)
    end
  end
  
  def store_class(cls)
    return @classes[cls] if @classes.include?(cls)
    hsh = self.store_class(cls.superclass)
    hsh[cls] = Hash.new
    @classes[cls] = hsh[cls]
  end
  
  def new_methods_liststore_for_class(class_name, methods_type)
    liststore = Gtk::ListStore.new(String, String)
    cls = Kernel.const_get(class_name)
    cls.public_instance_methods(false).each do |mth| 
      iter = liststore.append
      iter[0] = "+ " + mth.to_s
      iter[1] = mth.to_s
    end
    cls.private_instance_methods(false).each do |mth| 
      iter = liststore.append
      iter[0] = "- " + mth.to_s
      iter[1] = mth.to_s
    end
    cls.protected_instance_methods(false).each do |mth| 
      iter = liststore.append
      iter[0] = "# " + mth.to_s
      iter[1] = mth.to_s
    end
    liststore.set_sort_column_id(0)
    liststore
  end
  def register_methods_view_for_class(view, class_iter, methods_type)
    key = class_iter[0] + '#' + methods_type.to_s
    if !@methods_liststores.include?(key)
      liststore = self.new_methods_liststore_for_class(class_iter[0], methods_type)
      @methods_liststores[key] = {liststore => []}
    end
    @methods_liststores[key].values.first << view
    view.model = @methods_liststores[key].keys.first
    true
  end
  def unregister_methods_view_for_class(view, class_iter, methods_type)
    key = class_iter[0] + '#' + methods_type.to_s
    return true if !@methods_liststores.include?(key)
    puts "problem" if @methods_liststores[key].values.first.delete(view).nil?
    @methods_liststores.delete(key) if @methods_liststores[key].values.first.size == 0
    view.model = nil
    true
  end
end