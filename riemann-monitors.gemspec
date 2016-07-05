Gem::Specification.new do |s|
  s.name        = "riemann-monitors"
  s.version     = "0.0.1"
  s.licenses    = ["LGPL-3.0"]
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Tiny programs to submit events to Riemann."
  s.description = "This is a polite fork of riemann-tools, using my riemann-ruby-experiments gem instead of riemann-ruby-client.  As a result, events can be batched together to be sent in one message to a Riemann server.  Additionally, more control over the TCP socket options is given, and UDP isn&#8217;t supported (yet?), because this gem primarily uses net_ruby_client."
  s.authors     = ["Chris Riddoch"]
  s.email       = "riddochc@gmail.com"
  s.date        = "2016-07-05"
  s.homepage    = "https://github.com/riddochc/riemann-monitors"
  s.bindir      = "bin"

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
  s.executables = ["riemann-apache-status",
                   "riemann-bench",
                   "riemann-cloudant",
                   "riemann-consul",
                   "riemann-dir-files-count",
                   "riemann-dir-space",
                   "riemann-diskstats",
                   "riemann-fd",
                   "riemann-freeswitch",
                   "riemann-haproxy",
                   "riemann-health",
                   "riemann-httpstatus",
                   "riemann-kvminstance",
                   "riemann-memcached",
                   "riemann-net",
                   "riemann-nginx-status",
                   "riemann-ntp",
                   "riemann-proc",
                   "riemann-varnish",
                   "riemann-zookeeper"]

  s.add_dependency "riemann-ruby-experiments", ">= 0.0.2"
  s.add_dependency "trollop", ">= 1.16.2"
  s.add_dependency "json", ">= 1.8.3"

  s.add_development_dependency "rake", "= 11.2.2"
  s.add_development_dependency "asciidoctor", "= 1.5.5.dev"
  s.add_development_dependency "yard", "= 0.8.7.6"
  s.add_development_dependency "pry", "= 0.10.3"
  s.add_development_dependency "rugged", "= 0.24.0"
  s.add_development_dependency "ruby-builtin-requireables", "= 0.0.1"
end
