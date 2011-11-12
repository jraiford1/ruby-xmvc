require 'gtk2'
require_relative '../xmvc/application'

module GMVC
  class DevApplication < XMVC::DevApplication
    def should_build_scaffolding?
      if self.instance_of?(DevApplication)
        puts 'Error trying to build scaffolding for XMVC::DevApplication.  A subclass should be used.'
        return false
      end
      super
    end
    def build_scaffolding
      super
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'view'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'controller'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'gtk2', 'glade'))
      Dir.glob(File.join(@project_directory, 'lib', 'gtk2', 'glade', '*.glade')) do |glade_file|
        self.process_glade_file(glade_file)
      end
    end
    def process_glade_file(glade_file)
      file_hash = Hash.new
      file_hash[:glade] = glade_file
      builder = Gtk::Builder.new
      builder.add_from_file(glade_file)
      file_hash[:builder] = builder
      base = File.basename(glade_file, '.glade')
      file_hash[:model] = File.join(@project_directory, 'lib', 'model', base + '_model.rb')
      file_hash[:window] = File.join(@project_directory, 'lib', 'window', base + '_window.rb')
      file_hash[:controller] = File.join(@project_directory, 'lib', 'gtk2', 'controller', base + '_controller.rb')
      file_hash[:sig_handler] = Hash.new
      builder.connect_signals do |handler|
        file_hash[:sig_handler][handler] = nil
        nil
      end
      file_hash[:view] = Hash.new
      builder.objects.each do |obj|
        if obj.kind_of?(Gtk::Window)
          file_hash[:view][obj.builder_name] = File.join(@project_directory, 'lib', 'gtk2', 'view', base + '_view_' + obj.builder_name + '.rb')
        end
      end
      file_hash
    end
  end
end
