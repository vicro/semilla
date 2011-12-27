require "rake"

module Semilla

  class TestCaseFile
    attr_accessor :path

    #Constructor. The parameter should be a string from rake
    def initialize(fpath)
      @path = fpath
    end


    #The file name without extension
    def name
      @path.pathmap '%n'
    end


    #Get the package name from the contents of the file
    def package
      if !@_package
        #Open the file
        File.open @path do |io|
          io.each do |line|
            #Search for the package name
            if line =~ /^package (.*)/
              @_package = $1.rstrip
            end
          end
          #no package name found, set to empty string
          @_package = "" if !@_package
        end
      end
      return @_package
    end


    #The import statement for this class
    def import
      if self.package != ""
        return "#{self.package}.#{self.name}"
      else
        return self.name
      end
    end
  end


######################################################################
#Define a rake task for auto generating the TestRunner code
  def self.test_runner(output, files, port=1026, template="test-src/TestRunner.template")
    #Prepare arguments for the FileTask
    files.include template
    args = Array.new
    args << {output => files} #target file => dependencies

    body = proc {
      #create the test case generators
      generators = Array.new
      files.each do |f|
        tc = TestCaseFile.new f
        puts "[testRunner] Adding: #{tc.import}"
        generators << tc
      end
      #open the template and insert the import statements and class list
      File.open template do |io|
        txt = io.read
        #insert import list
        txt.sub! "@@IMPORTS@@", generators.map { |t| "\timport #{t.import};" }.join("\n")
        #insert class names
        txt.sub! "@@CLASSES@@", generators.map { |t| t.name }.join(",")
        #insert port number
        txt.sub! "@@PORT@@", port.to_s

        #write the generated code
        generated = File.new output, "w"
        generated.write txt
        generated.close
      end
    }

    #Create the file task (checks for dependency updates for us)
    Rake::FileTask.define_task(*args, &body)
  end

end
