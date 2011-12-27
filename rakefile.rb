require 'rubygems'
require 'rake/clean'
require 'rake'
require_relative "lib/semilla/version"


version = Semilla::VERSION
gemfile = "semilla-#{version}.gem"
gemspecfile = "semilla.gemspec"
########################################################################################################################

#####################################
#Clean
CLEAN << FileList["*.gem"]


#####################################
#Build the gem file
file gemfile => [gemspecfile] do |t|
  sh "gem build #{gemspecfile}"
end

desc "Builds the gem"
task :build => gemfile

####################################
desc "Uninstall the gem"
task :uninstall do |t|
  sh "gem uninstall semilla"
end

##################################
desc "Install the gem"
task :install => :build do |t|
  sh "gem install #{gemfile}"
end

##################################
task :default => [:clean, :build, :install]