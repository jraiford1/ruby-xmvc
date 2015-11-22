module XMVCApp
  class ClassHeirarchyBrowserModel < XMVC::Model

    def save_changes
      true
    end

    def load_classes
      @classes = {nil => Hash.new}
      ObjectSpace.each_object(Class) { |cls| self.store_class(cls) }
    end

    def store_class(cls)
      return @classes[cls] if @classes.include?(cls)
      hsh = self.store_class(cls.superclass)
      hsh[cls] = Hash.new
      @classes[cls] = hsh[cls]
    end

    def root_classes
      # This should answer BasicObject
      @classes.select {|cls| cls && cls.superclass.nil?}.keys
    end
    def classes
      #self.load_classes if @classes.nil?
      #@classes
      CHBApp.instance.class_info_hash
    end
  end
end
