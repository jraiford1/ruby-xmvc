require 'set'
require 'method_source'

module XMVCApp
  class CodeInfo
    attr_reader :visibility
    def private?
      @visibility == :private
    end
    def public?
      @visibility == :public
    end
    def protected?
      @visibility == :protected
    end
  end
  class MethodInfo < CodeInfo
    attr_accessor :method_name, :real_method
    attr_reader :class_info, :method_type
    def initialize(class_info, method_name, method_type)
      super()
      @class_info = class_info
      @method_name = method_name
      @method_type = method_type
      #puts "#{class_info.real_class}.#{method_name} (#{@method_type})"
      case method_type
      when :instance_methods
        @real_method = class_info.real_class.instance_method(@method_name)
        #puts @real_method
      when :class_methods
        @real_method = class_info.real_class.singleton_method(@method_name)
        #puts @real_method
      else
        @real_method = nil
      end
      begin
        @source_code_history = [@real_method.source]
      rescue Exception => exception
        @source_code_history = []
      end
    end
    def source_code
      if (@source_code_history.size == 0)
        "<Source code not available>"
        RubyVM::InstructionSequence.disasm(@real_method)
      else
        @source_code_history.last
      end
    end
  end
  class MethodSource
    attr_accessor :method_info, :changed_on, :source_code
    def initialize(method_info, source_code)
      @method_info = method_info
      @source_code = source_code
      self.process_header
    end
    def process_header
    end
  end
  class ClassInfo < CodeInfo
    attr_accessor :superclass, :real_class, :subclasses, :class_name
    def initialize(a_class)
      super()
      @subclasses = Set.new
      @real_class = a_class
      @class_name = a_class.name.to_sym
    end
    def inst_methods
      @inst_methods ||= MethodInfoHash.new(self, @real_class.instance_methods(false), :instance_methods)
    end
    def cls_methods
      @cls_methods ||= MethodInfoHash.new(self, @real_class.singleton_methods(false), :class_methods)
    end
  end
  class CodeInfoHash
    attr_reader :encapsulated_hash
    def initialize
      @encapsulated_hash = Hash.new
    end
    def method_missing(aSymbol, *args, &block)
      if @encapsulated_hash.respond_to?(aSymbol)
        @encapsulated_hash.send(aSymbol, *args, &block)
      else
        super
      end
    end
    def respond_to?(aSymbol, include_private = false)
      if @encapsulated_hash.respond_to?(aSymbol)
        return true
      else
        super
      end
    end
  end

  class ClassInfoHash < CodeInfoHash
    attr_reader :root_classes
    def initialize
      super
      ObjectSpace.each_object(Class) { |a_class| self.add_class(a_class) }
    end
    def add_class(a_class)
      if a_class.nil? || a_class.name.nil?
        return nil
      end
      class_symbol = a_class.name.to_sym
      class_info = self[class_symbol]
      if !class_info.nil?
        return class_info
      else
        class_info = ClassInfo.new(a_class)
        self[class_symbol] = class_info
      end
      superclass_info = self.add_class(a_class.superclass)
      if superclass_info.nil?
        self.add_root_class(class_info)
      else
        class_info.superclass = superclass_info
        superclass_info.subclasses.add(class_info)
      end
      class_info
    end
    def add_root_class(a_class_info)
      @root_classes ||= Set.new
      @root_classes.add(a_class_info)
    end
  end
  class MethodInfoHash < CodeInfoHash
    def initialize(class_info, method_names, methods_type)
      super()
      @class_info = class_info
      @methods_type = methods_type
      method_names.each do |method_name|
        self[method_name] = MethodInfo.new(class_info, method_name, methods_type)
      end
    end
  end
end
