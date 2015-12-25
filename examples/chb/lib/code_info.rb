require 'set'
require 'method_source'
require 'parser/current'

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
    end
    def init_method
      case @method_type
      when :instance_methods
        @real_method = @class_info.real_class.instance_method(@method_name)
      when :class_methods
        @real_method = @class_info.real_class.singleton_method(@method_name)
      else
        raise "Invalid method type"
      end
      @source_code_history ||= []
      begin
        @source_code_history << @real_method.source
      rescue Exception => exception
        begin
          source_code = RubyVM::InstructionSequence.disasm(@real_method)
          if source_code.nil? then
            source_code  = "<Source code not available>"
          end
          @source_code_history << source_code
        rescue Exception => exception2
          @source_code_history << "<Source code not available>"
        end
      end
    end
    def update_method(source_code)
      case @method_type
      when :instance_methods
        @real_method = @class_info.real_class.instance_method(@method_name)
      when :class_methods
        @real_method = @class_info.real_class.singleton_method(@method_name)
      else
        raise "Invalid method type"
      end
      @source_code_history ||= []
      @source_code_history << source_code
    end
    def source_code
      if (@source_code_history.nil?) then
        self.init_method
      end
      @source_code_history.last
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
    def add_method_from_source(raw_source_code, method_type)
      return nil if raw_source_code.nil?
      parser = Parser::CurrentRuby.parse_with_comments(raw_source_code)
      #TODO - build the source code from the parse tree for consistent code and to eliminate tricks
      source_code = raw_source_code
      case method_type
      when :instance_methods
        if (parser[0].type == :def) then
          @real_class.class_eval(source_code)
          method_name = parser[0].children[0]
          method_info = @inst_methods[method_name] ||= MethodInfo.new(self, method_name, method_type)
          method_info.update_method(source_code)
          return method_info
        end
        error_msg = "Invalid class method definition"
      when :class_methods
        if (parser[0].type == :defs) & (parser[0].children[0].type == :self) then
          @real_class.instance_eval(source_code)
          method_name = parser[0].children[1]
          method_info = @cls_methods[method_name] ||= MethodInfo.new(self, method_name, method_type)
          method_info.source_code = source_code
          return method_info
        end
        error_msg = "Invalid class method definition"
      else
        error_msg = "Invalid method type"
      end
      raise error_msg
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
