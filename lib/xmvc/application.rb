module XMVC
  class Application
    def run
      self.main
    end
    # main should be implemented by subclass
    def main ; end
  end
  class DevApplication < Application
    def run
      if self.should_build_scaffolding?
        src = self.method(:main).source_location
        if src
          @project_directory, lib = File.split(File.split(src.first).first)
          if lib != 'lib'
            puts 'Error building scaffolding: Source file is not in a project lib directory'
          else
            self.build_scaffolding
          end
        end
      end
      super
    end
    def should_build_scaffolding?
      if self.instance_of?(DevApplication)
        puts 'Error trying to build scaffolding for XMVC::DevApplication.  A subclass should be used.'
        return false
      elsif !self.class.instance_methods(false).include?(:main)
        puts 'Unable to build scaffolding unless instance method :main is implemented'
        return false
      end
      true
    end
    def create_project_directory(path)
      if !File.directory?(path)
        Dir::mkdir(path)
        puts 'Directory created: ' + path
      end
    end
    def build_scaffolding
      self.create_project_directory(File.join(@project_directory, 'bin'))
      self.create_project_directory(File.join(@project_directory, 'test'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'window'))
      self.create_project_directory(File.join(@project_directory, 'lib', 'model'))
    end
  end
end

