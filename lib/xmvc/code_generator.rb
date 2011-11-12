require 'set'

module XMVC
  class RubyFile
    attr_accessor :file_name, :rf_requires, :rf_require_relatives, :rf_file_methods, :rf_module, :rf_module_methods, :rf_class, :rf_class_methods, :rf_instance_methods
    def initialize
      @rf_requires = Array.new
      @rf_require_relatives = Array.new
      @rf_file_methods = Set.new
      @rf_module_methods = Set.new
      @rf_class_methods = Set.new
      @rf_instance_methods = Set.new
    end
  end
end