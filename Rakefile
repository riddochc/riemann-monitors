# vim: syntax=ruby

require 'yaml'
require 'find'
require 'asciidoctor'
require 'erb'

require 'yaml'
require 'find'
require 'erb'
require 'set'

begin
  require 'asciidoctor'
  require 'yard'
  require 'rugged'
  require 'ruby-builtin-requireables'
rescue LoadError => e
  puts "You're missing the #{e.message[/\S+$/]} gem, some tasks may not work as expected... but build and install should."
  exit -1
end

def installed_gem_versions
  rx = /^(?<name>\S+)\s\((?<versions>[^)]+)/
  gems = {}
  IO.popen(%w(gem list -l)).readlines
    .map {|line| m = rx.match(line) }
    .compact
    .map {|m| gems[m['name']] = m['versions'].split(', ')
                                  .map {|v| begin
                                              Gem::Version.new(v)
                                            rescue ArgumentError
                                              nil
                                            end
                                  }.compact.max_by(&:itself)
         }
  gems
end

def filtered_project_files()
  Dir.chdir __dir__ do
    Find.find(".").reject {|f|
      !File.file?(f) ||
       f =~ %r{^\./(.git|tmp|search)} ||
       f =~ %r{\.(so|gem)$}
    }.map {|f| f.sub %r{^\./}, '' }
  end
end


adoc = Asciidoctor.load_file("README.adoc")
summary = adoc.sections.find {|s| s.name == "Description" }.blocks[0].content.gsub(/\n/, ' ')
description = adoc.sections.find {|s| s.name == "Description" }.blocks[1].content.gsub(/\n/, ' ')
config = YAML.load_file(File.join(__dir__, "project.yaml"))
project = config.fetch('name', File.split(File.expand_path(__dir__)).last)
toplevel_module = config.fetch('toplevel_module') { project.capitalize }
version = adoc.attributes['revnumber']
dependencies = config.fetch('dependencies', {})
if dependencies.nil?
  dependencies = {}
end
dev_dependencies = config.fetch('dev-dependencies', {})
if dev_dependencies.nil?
  dev_dependencies = {}
end
license = config.fetch('license') { "LGPL-3.0" }
files = filtered_project_files()
exec_files = filtered_project_files().select {|f| f.start_with?("bin/") }.map {|f| f.gsub(%r{bin/}, '') }

gemspec_template = <<GEMSPEC
Gem::Specification.new do |s|
  s.name        = "<%= project %>"
  s.version     = "<%= version %>"
  s.licenses    = ["<%= license %>"]
  s.platform    = Gem::Platform::RUBY
  s.summary     = <%= summary.inspect %>
  s.description = <%= description.inspect %>
  s.authors     = ["<%= adoc.author %>"]
  s.email       = "<%= adoc.attributes['email'] %>"
  s.date        = "<%= Date.today %>"
  s.homepage    = "<%= adoc.attributes['homepage'] %>"
  s.bindir      = "bin"

  s.files       = [<%= files.map{|f| '"' + f + '"' }.join(",\n                   ") %>]
% if exec_files.length > 0
  s.executables = [<%= exec_files.map{|f| '"' + f + '"' }.join(",\n                   ") %>]
% end

% dependencies.each_pair do |req, vers|
  s.add_dependency "<%= req %>", "<%= vers %>"
% end

% dev_dependencies.each_pair do |req, vers|
  s.add_development_dependency "<%= req %>", "<%= vers %>"
% end
end
GEMSPEC

task default: [:clean, :gen_version, :gemspec, :gemfile, :build]

task :git_check do
  repo = Rugged::Repository.new(".")
  unless repo_clean?(repo)
    puts "Warning: repository contains uncommitted changes!"
  end
end

task :gen_version do
  File.open(File.join("lib", project, "version.rb"), 'w') {|f|
    f.puts "module #{toplevel_module}"
    major, minor, tiny = *version.split(/\./).map {|p| p.to_i }
    f.puts '  VERSION = "' + version + '"'
    f.puts "  VERSION_MAJOR = #{major}"
    f.puts "  VERSION_MINOR = #{minor}"
    f.puts "  VERSION_TINY = #{tiny}"
    f.puts "end"
  }
end

task :gemspec => [:gen_version] do
  requires = filtered_project_files()
    .map {|f| File.readlines(f).grep (/^\s*require(?!_relative)\b/) }
    .flatten
    .map {|line| line.split(/['"]/).at(1) }
    .compact
    .uniq
    .grep_v(/<%=|%>|#|\$/)
  requires.delete(project)

  builtin_requireables = IO.popen("ruby-builtin-requireables").readlines.map(&:chomp)

  available_gems = installed_gem_versions()
  gem_names = available_gems.keys.to_set
  basic_requirements = {}
  ["rake", "asciidoctor", "yard", "pry", "rugged", "ruby-builtin-requireables"].each {|g|
    basic_requirements[g] = "= #{available_gems[g]}"
  }

  req_names = basic_requirements.keys.to_set
  if !gem_names.superset?(req_names)
    puts "Missing dev dependencies: " + (req_names - gem_names).to_a.join(', ')
  else
    dev_dependencies = basic_requirements.merge(dev_dependencies)
  end

  # Catch cases like 'require "some_gem/subpart"'
  preslash_subgems = Regexp.new("^" + Regexp.union(dev_dependencies.keys + dependencies.keys).to_s + "/")
  subgem_dependencies = requires.grep(preslash_subgems)

  missing_deps = (requires - builtin_requireables - dependencies.keys - dev_dependencies.keys - subgem_dependencies)
  if missing_deps.length > 0
    puts "There may be some dependencies not listed in project.yml:"
    puts missing_deps.join(", ")
  end

  File.open(project + ".gemspec", 'w') do |f|
    erb = ERB.new(gemspec_template, nil, "%<>")
    f.write(erb.result(binding))
  end
end

task :gemfile do
  unless File.exists?("Gemfile")
    File.open("Gemfile", 'w') do |f|
      f.puts "source 'https://rubygems.org'"
      f.puts "gemspec"
      f.puts
    end
  end
end

task :build => [:clean, :gemspec, :gemfile] do
  system "gem build #{project}.gemspec"
end

task :install => [:build] do
  system "gem install ./#{project}-#{version}.gem"
end

task :readme do
  sh "asciidoctor", "README.adoc"
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.options = ['asciidoc'] # optional
  t.stats_options = ['--list-undoc']         # optional
end

task :starscope => [:search_clean] do
  File.open("cscope.files", "w") {|flist|
    filtered_project_files().grep(%r{^lib/.*\.rb$})
      .each {|f| flist.puts(f) }
  }
  sh *%w{starscope -e cscope}
  sh *%w{ctags --fields=+i -n -L cscope.files}
  mkdir "search"
  rm "cscope.files"
  %w[.starscope.db cscope.out tags].each {|f| mv f, "search" }
end

task :codequery => [:starscope] do
  cd "search" do
    cmd = ["cqmakedb", "-s", "#{project}-codequery.db"]
    cmd += %w[-c cscope.out -t tags -p]
    sh *cmd
  end
end

task :search_clean do
  rm_rf "./starscope"
end

task :clean => [:search_clean] do
  rm_f "./#{project}-#{version}.gem"
  rm_f "./lib/#{project}/version.rb"
  rm_f "./#{project}.gemspec"
  rm_f "./README.html"
  rm_rf "./doc"
  rm_rf "./.yardoc"
end

