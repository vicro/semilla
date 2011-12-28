
# -*- encoding: utf-8 -*-
#$:.push('lib')
require "semilla/version"

Gem::Specification.new do |s|
  s.name     = "semilla"
  s.version  = Semilla::VERSION.dup
  s.date     = "2011-12-26"
  s.summary  = "Rake tasks for flexunit4"
  s.email    = "support@semilla.com"
  s.homepage = "https://github.com/Darkoleptiko/semilla"
  s.authors  = ['Victor G. Rosales']
  
  s.description = <<-EOF
Rake tasks for executing flex unit 4 tests.
It should be used in addition to the sprout gem.
EOF
  
  dependencies = [
    # Examples:
    # [:runtime,     "rack",  "~> 1.1"],
    # [:development, "rspec", "~> 2.1"],
      [:sprout_flashsdk, "flashsdk", "~> 1.0"]
  ]
  
  s.files         = Dir['**/*']
  s.test_files    = Dir['test/**/*'] + Dir['spec/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.8.13"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
  
  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
