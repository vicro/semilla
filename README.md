
# Semilla Gem #

This gem adds some rake tasks for testing ActionScript applications with the FlexUnit4 testing framework.


## Installation ##

To install with rake:

	$ rake

To install with gem:

	$ gem build semilla.gemspec
	$ gem install semilla-VERSION.gem


## Usage ##

Generate a TestRunner

	Semilla::test_runner "outputfile.as", FileList["test-src/**/*Test.as"], 1026


Run the test and obtain a report.

	Semilla::flex_unit :taskname => [dependencies]] do |t|
		t.serverPort = 1026
		t.swf = "app.swf"
		t.reportpath = "reports"
		t.timeout = 10
	end

## MIT License ##

<pre>
Copyright (c)2011-2012 Victor G. Rosales

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
</pre>