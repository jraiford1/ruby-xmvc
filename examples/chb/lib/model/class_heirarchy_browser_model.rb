module XMVCApp
  class CHBModel < GMVC::SuperModel
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
    
  end
end