require 'rexml/document'
require 'rexml/formatters/default'
require 'socket'
require 'time'


module Semilla

#Define a test case
  class FlexUnitTestCase

    attr_accessor :classname, :name, :time, :status, :msg


    def initWith(xml)
      #parse tag
      if xml.is_a? String
        doc = REXML::Document.new xml
      else
        doc = REXML::Document.new
        doc.add_element xml
      end


      @classname = doc.root.attribute("classname").value.sub "::", "." #Change the :: to .
      @name      = doc.root.attribute("name").value                    #method name
      @time      = doc.root.attribute("time").value.to_i / 1000.0      #time to milliseconds
      @status    = doc.root.attribute("status").value                  #status
      @msg = doc.root.elements[1] if doc.root.elements.count > 0


      #If time is reported as 0 by flex unit, set to 1 millisecond
      #@time = 1/1000.0 if @time == 0
    end


    def toXml
      element = REXML::Element.new "testcase"
      element.add_attribute "classname", @classname
      element.add_attribute "name", @name
      element.add_attribute "time", @time
      element.add_attribute "status", @status
      element.add_element @msg unless @msg.nil?

      return element
    end
  end

#Defin a test suite
  class FlexUnitTestSuite

    def initialize
      @testCases = Array.new
      @classname = ""
      @totalTime = 0.0
      @id        = 0
    end


    attr_reader :totalTime, :classname
    attr_accessor :id


    def addCase(tc)
      if tc.is_a? FlexUnitTestCase
        @classname = tc.classname
        @testCases << tc
        @totalTime = @totalTime + tc.time
      end
    end


    def testCount
      @testCases.count
    end


    def name
      return @classname[/[^\.]*$/] #Get the text at the end of the line after the last dot
    end


    def package
      if @classname.include? "."
        @classname[/(?<package>.*)([\.])/, "package"]
        #using named captures check: "?<package>"
      else
        ""
      end
    end


    def failures
      return @testCases.count { |tc| tc.status == "failure" }
    end


    def errors
      return @testCases.count { |tc| tc.status == "error" }
    end


    def ignores
      return @testCases.count { |tc| tc.status == "ignore" }
    end


    def toXml
      element = REXML::Element.new "testsuite"
      element.add_attribute "hostname", Socket.gethostname
      element.add_attribute "id", self.id
      #element.add_attribute "package", self.package
      element.add_attribute "name", self.classname
      element.add_attribute "tests", self.testCount
      element.add_attribute "failures", self.failures
      element.add_attribute "errors", self.errors
      element.add_attribute "skipped", self.ignores
      element.add_attribute "time", self.totalTime
      element.add_attribute "timestamp", Time.now.utc.iso8601

      @testCases.each do |tc|
        element.add_element tc.toXml
      end

      return element
    end

  end


  def self.writePrettyXml(element, filename)
    #create anew xml document
    outdoc         = REXML::Document.new

    #Create the xml declaration
    xmldeclaration = REXML::XMLDecl.new
    xmldeclaration.dowrite
    xmldeclaration.encoding = "UTF-8"
    outdoc << xmldeclaration

    #Add the element
    outdoc << element

    #Write to a file
    f         = File.new filename, "w"
    formatter = REXML::Formatters::Pretty.new
    formatter.write(outdoc, f)
    f.close
  end


#converts an xml report from flash, into an array of FlexUnitTestSuite
  def self.processReports(xmlresults)

    testResults = REXML::Document.new xmlresults

    suites = Hash.new

    testResults.elements.each "report/testcase" do |element|

      #Create the testcase
      tc = FlexUnitTestCase.new
      tc.initWith element

      #Check if we dont have a suite for the classname
      unless suites.has_key? tc.classname
        #make a new suite
        s                    = FlexUnitTestSuite.new
        suites[tc.classname] = s
      end

      suite = suites[tc.classname]
      suite.addCase tc
      puts "    [TestCase] #{tc.classname} => #{tc.name}, #{tc.status}"
    end

    return suites
  end


#writes junit xml files for each item in the suites hash
  def self.createReports(suites, outfolder = "test-report")

    testcount   = 0
    testfails   = 0
    testerr     = 0
    testignores = 0
    suites.each do |name, suite|
      #write individual report file
      writePrettyXml suite.toXml, "#{outfolder}/TEST-#{suite.classname}.xml"
      testcount   += suite.testCount
      testfails   += suite.failures
      testerr     += suite.errors
      testignores += suite.ignores
    end

    testPassed = testcount - testfails - testerr - testignores
    testok     = testPassed.to_f / testcount.to_f * 100.0
    puts "Success [#{testPassed}/#{testcount}] #{sprintf('%.1f', testok)}%, Fails [#{testfails}], Errors [#{testerr}], Ignored [#{testignores}]"
    return testfails + testerr
  end

end