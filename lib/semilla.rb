

require 'semilla/report_server'
require 'semilla/reports'
require 'semilla/test'
require 'semilla/test_runner'


## Rake usage

=begin

#################################################################
# Rake task to create the test runner actionscript
#
# @param output file
# @param test classes file list
# @param report server port
Semilla::test_runner "outputfile.as", FileList["test-src/**/*Test.as"], 1026

#################################################################
# Rake task to test a swf and get a report in junit xml format.
#
# @param task id
# @param dependencies
Semilla::flex_unit :taskname => [dependencies]] do |t|
   #Configuration options
   #    serverPort :player, :swf, :reportpath, :timeout
   #    serverPort :player, :swf, :reportpath, :timeout
   t.serverPort = 1026
   t.swf = "app.swf"
   t.reportpath = "reports"
   t.timeout = 10
end

=end
