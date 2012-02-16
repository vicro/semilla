
require "rexml/document"
require "rake"
require 'timeout'
require 'flashplayer/trust'

require_relative "reports"
require_relative "report_server"


module Semilla
  class FlexUnitTestTask < Rake::Task

    attr_accessor :serverPort, :player, :swf, :reportpath, :timeout


    def initialize(task_name, app)
      super task_name, app

      @serverPort = 1024
      @player     = ENV['FLASH_PLAYER']
      @reportpath = "test-report"
      @timeout    = 10 #seconds
    end


    def execute(arg = nil)
      super arg

      ##Check the parameters
      if @serverPort.nil?
        fail "Server port not specified."
      end

      if @swf.nil?
        fail "No swf path specified."
      end

      if @reportpath.nil?
        fail "No report path specified."
      end

      #Writeout the FlashPlayerTrust file
      trust = FlashPlayer::Trust.new
      trust.add File.dirname(@swf)

      puts "[TEST] Start"
      server       = FlexUnitReportServer.new @serverPort
      serverThread = Thread.new {
        #Start the server for getting the flex unit results
        server.start @timeout
      }
      sleep 0.5

      #launch flash
      clientThread = Thread.new {

        begin
          status = Timeout::timeout @timeout do
            flashbin = ENV['FLASH_PLAYER']
            #Run the flash player
            puts "Running flash..."
            fr = Semilla::run_player(flashbin, swf)
          end
        rescue Timeout::Error
          fail "Flash player timeout!!!"
        end
      }


      #Wait until finished
      serverThread.join
      clientThread.join

      #parse the reports
      suites    = Semilla::processReports server.results
      #generate junit report
      failcount = Semilla::createReports suites, @reportpath
      puts "[TEST] Done"

      fail "Unit tests failed." if failcount > 0

    end

  end


  def self.flex_unit(*args, &body)
    FlexUnitTestTask.define_task(*args, &body)
  end


end
