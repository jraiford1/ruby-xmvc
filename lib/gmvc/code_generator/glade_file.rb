module GMVC
  class GladeFile
    attr_reader :filename, :window, :model, :views, :controllers, :mtime
    def initialize(filename)
      raise "Glade file doesn't exist! (#{filename})" if !File.exists?(filename)
      @filename = filename
      base = File.basename(@filename, '.glade')
      project_directory = File.absolute_path(File.join(File.split(@filename).first, '../../..'))
      @window = XMVC::WindowFile.new(File.join(project_directory, 'lib', 'window', base + '_window.rb'))
      @model = XMVC::ModelFile.new(File.join(project_directory, 'lib', 'model', base + '_model.rb'))
      @controller = GMVC::ControllerFile.new(File.join(project_directory, 'lib', 'gtk2', 'controller', base + '_controller.rb'))
      @views = Hash.new
    end
    # GMVC::GladeFile::has_updates
    # Return true if the glade file has updates (if its modification date is newer
    # than its supporting files)
    def has_updates?
      return true # assume there are changes for now
      return true if @controller.mtime.nil? or @mtime > @controller.mtime
      return true if @window.mtime.nil? # or @mtime > @window.mtime
      return true if @model.mtime.nil? # or @mtime > @model.mtime
      # return true if @views.empty?
      @views.each_value do |view|
        return true if view.mtime.nil? # or @mtime > view.mtime
      end
      false
    end
    def build_scaffolding
      
    end
    def load_file      
      @builder = Gtk::Builder.new
      @builder.add_from_file(@filename)
      
      hsh[:sig_handlers] = Hash.new
      builder.connect_signals do |handler|
        hsh[:sig_handlers][handler] = nil
        nil
      end
      
      hsh[:view_filenames] = Hash.new
      hsh[:view_files] = Hash.new
      builder.objects.each do |obj|
        if obj.kind_of?(Gtk::Window)
          hsh[:view_filenames][obj.builder_name] = File.join(@project_directory, 'lib', 'gtk2', 'view', base + '_view_' + obj.builder_name + '.rb')
          rf = XMVC::RubyFile.new
          hsh[:view_files][obj.builder_name] = rf if rf.load_from_file(hsh[:view_filenames][obj.builder_name])
        end
      end
      
      self.process_model_file(hsh)
      self.process_window_file(hsh)
      self.process_controller_file(hsh)
      self.process_view_files(hsh)
      
      hsh
    end
  end
end