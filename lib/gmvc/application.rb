require 'gtk2'
require_relative '../xmvc/application'

module GMVCApp
  def self.require_controller(controller_file)
    require File.join($project_directory, 'lib/gtk2/controller', controller_file)
  end
  def self.require_view(view_file)
    require File.join($project_directory, 'lib/gtk2/view', view_file)
  end
end

module GMVC
  
  class Application < XMVC::Application
    def windowing_system
      GMVCApp
    end
  end
  class DevApplication < XMVC::DevApplication
    
    # GMVC::DevApplication::require_code_generators
    # Load the code generators code.  Only does this if app is a DevApplication to
    # save time when running in runtime mode.
    def require_code_generators
      super
      require_relative 'code_generator'
    end
    
    # GMVC::DevApplication::should_build_scaffolding?
    # Return true if scaffolding should be created, false otherwise
    def should_build_scaffolding?
      if self.instance_of?(DevApplication)
        puts 'Error trying to build scaffolding for XMVC::DevApplication.  A subclass should be used.'
        return false
      end
      super
    end
    
    # GMVC::DevApplication::build_scaffolding
    # Based on the current code and files in the project, generate new directories
    # and files that are needed
    def build_scaffolding
      super
      @glade_files = Hash.new
      
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'view'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'controller'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'glade'))
      
      glade_dir = File.join(@project_directory, 'lib', 'gtk2', 'glade')
      return if !Dir.exists?(glade_dir)
      
      Dir.glob(File.join(glade_dir, '*.glade')) do |glade_filename; glade_file|
        glade_file = GladeFile.new(glade_filename)
        @glade_files[glade_filename] = glade_file if glade_file.has_updates?
      end
      
      return if @glade_files.empty?
      @glade_files.each_value do | glade_file |
        glade_file.build_scaffolding
      end
    end
    def process_model_file(hsh)
      if !hsh[:model_file]
        rf = XMVC::RubyFile.new
        rf.file_name = hsh[:model_filename]
        rf.rf_class_name = XMVC::convert_to_camelcase("#{hsh[:base_name]}_model")
        rf.rf_superclass_name = 'XMVC::Model'
        rf.create_file
      else
        # do nothing for now
      end
    end
  end
end
