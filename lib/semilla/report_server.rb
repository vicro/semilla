require "socket"
require "timeout"

module Semilla

  class FlexUnitReportServer

    attr_accessor :results
    attr_reader :error

    START_ACK          = "<startOfTestRunAck/>"
    END_TEST           = "<endOfTestRun/>"
    END_TEST_ACK       = "<endOfTestRunAck/>"
    POLICY_REQUEST     = "<policy-file-request/>"
    EOF                = "\0"
    SOCKET_POLICY_FILE = <<EOS
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="@@@"/>
</cross-domain-policy>
EOS


    def initialize(port=1026)
      @port   = port
      @addr   = "127.0.0.1"
      @server = nil #This will be our socket server
      @error  = false
    end


    def start(timeout=10)
      @server = TCPServer.new(@addr, @port)
      #view server data
      puts @server.addr

      #open the socket
      puts "Opening server at port #{@port}"

      #--------------------------------------------------------------
      #the report result will be here
      report = ""

      loop {
        puts "Waiting for client..."

        begin
          #Wait with a timeout
          client = Timeout::timeout timeout do
            @server.accept
          end
            #No client connected within the time limit, bail out
        rescue Timeout::Error
          puts "Timeout!!, no client connected!!!"
          @error = true
          break
        end
        puts "Client connected..."
        puts "Receiving data"
        #Tell FlexUnit to start sending stuff
        client.puts START_ACK + EOF
        #puts "[OUT] #{START_ACK}"
        report = "<report>"
        error  = false
        while received = receiveWithTimeout(client, timeout)
          unless received != ""
            finished = true
            puts "empty data!!"
            error = true
            break
          end
          #puts received
          putc '.'
          #clean up the text
          received.rstrip!
          received.chomp!

          #print out for debug
          #puts "[IN] #{received}"

          #check for policy file
          if received.include? POLICY_REQUEST
            self.sendPolicyFile client
            client.close
            puts "[OUT] Sending policy File"
            break
          end

          if received.include? END_TEST

            #the last message may contain some data as well
            report = report + received.sub(END_TEST, "")

            puts
            puts "Closing connection"
            #Test ended, send ACK to client
            client.puts END_TEST_ACK + EOF
            client.flush
            client.close
            finished = true
            report   = report + "</report>"
            break
          end

          report = report + received

        end

        if error
          report = nil
        end
        break if finished


      }
      #Parse the xml from flexunit and generate the report files.
      puts "bye bye"
      #sanitize the results string
      @results = report.delete "\000" unless report.nil?
      #---------------------------------------------------------------

    end


    def policyFile
      return SOCKET_POLICY_FILE.sub "@@@", @port #replace the @@@ for the port number
    end


    def sendPolicyFile(client)
      puts "Sending policy file."
      #Send policy stuff
      client.puts self.policyFile
      client.flush
    end


    def receiveWithTimeout(client, timeout)

      begin
        r = Timeout::timeout timeout do
          client.recv(1024)
        end
      rescue Timeout::Error
        "" #Timed out, return an empty string
      end

    end

  end

end