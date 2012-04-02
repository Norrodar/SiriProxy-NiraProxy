# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-niraproxy"
  s.version     = "0.5.0" 
  s.authors     = ["Niranda"]
  s.email       = ["admin@niranda.net"]
  s.homepage    = "http://www.Niranda.net"
  s.summary     = %q{A NiraProxy Plugin}
  s.description = %q{This is a Plugin for SiriProxy to use the NiraProxy-API}

  s.rubyforge_project = "siriproxy-niraproxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
   s.add_runtime_dependency "url_escape"
end
