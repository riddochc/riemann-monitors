Gem::Specification.new do |s|
  s.name        = "riemann-monitors"
  s.version     = "0.0.1"
  s.licenses    = ["LGPL-3.0"]
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Tiny programs to submit events to Riemann."
  s.description = "This is a polite fork of riemann-tools, using my riemann-ruby-experiments gem instead of riemann-ruby-client.  As a result, events can be batched together to be sent in one message to a Riemann server.  Additionally, more control over the TCP socket options is given, and UDP is less supported as a result of that gem&#8217;s use of net_ruby_client."
  s.authors     = ["Chris Riddoch"]
  s.email       = "riddochc@gmail.com"
  s.date        = "2016-05-30"
  s.files       = ["Gemfile",
                   "LICENSE",
                   "README.adoc",
                   "Rakefile",
                   "bin/riemann-apache-status",
                   "bin/riemann-bench",
                   "bin/riemann-cloudant",
                   "bin/riemann-consul",
                   "bin/riemann-dir-files-count",
                   "bin/riemann-dir-space",
                   "bin/riemann-diskstats",
                   "bin/riemann-fd",
                   "bin/riemann-freeswitch",
                   "bin/riemann-haproxy",
                   "bin/riemann-health",
                   "bin/riemann-httpstatus",
                   "bin/riemann-kvminstance",
                   "bin/riemann-memcached",
                   "bin/riemann-net",
                   "bin/riemann-nginx-status",
                   "bin/riemann-ntp",
                   "bin/riemann-proc",
                   "bin/riemann-varnish",
                   "bin/riemann-zookeeper",
                   "data/statfields",
                   "lib/riemann-monitors/main.rb",
                   "lib/riemann-monitors/version.rb",
                   "lib/riemann-monitors.rb",
                   "project.yaml",
                   "riemann-monitors.gemspec"]
  s.homepage    = "https://github.com/riddochc/riemann-monitors"
  s.bindir      = "bin"
  s.executables = ["riemann-kvminstance",
                   "riemann-dir-files-count",
                   "riemann-ntp",
                   "riemann-diskstats",
                   "riemann-dir-space",
                   "riemann-net",
                   "riemann-varnish",
                   "riemann-apache-status",
                   "riemann-consul",
                   "riemann-haproxy",
                   "riemann-freeswitch",
                   "riemann-cloudant",
                   "riemann-bench",
                   "riemann-proc",
                   "riemann-health",
                   "riemann-zookeeper",
                   "riemann-httpstatus",
                   "riemann-memcached",
                   "riemann-nginx-status",
                   "riemann-fd"]

  s.add_dependency "riemann-ruby-experiments", ">= 0.0.2"
  s.add_dependency "trollop", ">= 1.16.2"
  s.add_dependency "json", ">= 1.8.3"

  s.add_development_dependency "rake", "=10.5.0"
  s.add_development_dependency "asciidoctor", "=1.5.5.dev"
  s.add_development_dependency "yard", "=0.8.7.6"
  s.add_development_dependency "pry", "=0.10.3"
  s.add_development_dependency "rspec", "=3.4.0"
end
