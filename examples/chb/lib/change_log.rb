# 2015-12-25 23:38:21 -0500
class XMVCApp::ClassInfo
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
          method_info.update_method(source_code)
          return method_info
        end
        error_msg = "Invalid class method definition"
      else
        error_msg = "Invalid method type"
      end
      raise error_msg
    end
end

# 2015-12-25 23:38:35 -0500
class GMVC::Controller
    def self.window_name
      # comment
      self.name.split("::").last.downcase
    end
end

