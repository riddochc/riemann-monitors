require 'pry'
require 'openssl'

class Hash
  def has_keys?(*rest)
    rest.all? {|k| self.has_key?(k) }
  end
end

module Riemann
  module Monitors
    require 'trollop'
    require 'riemann-ruby-experiments'

    def self.included(base)
      base.instance_eval do
        def run
          new.run
        end

        def opt(*a)
          a.unshift :opt
          @opts ||= []
          @opts << a
        end

        def options
          p = Trollop::Parser.new
          @opts.each do |o|
            p.send *o
          end
          Trollop::with_standard_exception_handling(p) do
            p.parse ARGV
          end
        end

        opt :host, "Riemann host", :default => '127.0.0.1'
        opt :port, "Riemann port", :default => 5555
        opt :event_host, "Event hostname", :type => String
        opt :interval, "Seconds between updates", :default => 5
        opt :tag, "Tag to add to events", :type => String, :multi => true
        opt :ttl, "TTL for events", :type => Integer
        opt :attribute, "Attribute to add to the event", :type => String, :multi => true
        opt :timeout, "Timeout (in seconds) when waiting for acknowledgements", :default => 30
        opt :tcp, "Use TCP transport instead of UDP (improves reliability, slight overhead.", :default => true
        opt :ssl_ca_file, "SSL certificate authority cert", :default => File.join(Dir.home, ".config", "riemann-tools", "ca.crt")
        opt :ssl_cert_file, "SSL client certificate public key", :default => File.join(Dir.home, ".config", "riemann-tools", "#{Socket.gethostname}.crt")
        opt :ssl_key_file, "SSL client certificate private key", :default => File.join(Dir.home, ".config", "riemann-tools", "#{Socket.gethostname}.key")
      end
    end

    # Returns parsed options (cached) from command line.
    def options
      @options ||= self.class.options
    end
    alias :opts :options

    def attributes
      @attributes ||= Hash[options[:attribute].map do |attr|
        k,v = attr.split(/=/)
        if k and v
          [k.to_sym,v]
        end
      end]
    end

    def report(event_hash)
      event_hash[:tags] = (event_hash[:tags] || []) + (options[:tag] || [])
      event_hash[:ttl] ||= (options[:ttl] || (options[:interval] * 2))
      event_hash[:host] ||= options[:event_host]
      event_hash.merge!(attributes)
      riemann.add_event(event_hash)
    end

    def new_riemann_client
      riemann_options = {
        :server  => "#{options[:host]}:#{options[:port]}",
        :connect_timeout => options[:timeout]
      }
      if options.has_keys?(:ssl_ca_file, :ssl_cert_file, :ssl_key_file)
        # These are given to OpenSSL::SSL::SSLContext
        riemann_options[:ssl] = {
          ca_file: File.expand_path(options[:ssl_ca_file]),
          cert:    OpenSSL::X509::Certificate.new(File.read(File.expand_path(options[:ssl_cert_file]))),
          key:     OpenSSL::PKey::RSA.new(File.read(File.expand_path(options[:ssl_key_file]))),
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          ssl_version: :TLSv1_2
        }
      end
      Riemann::Experiment::Client.new(riemann_options)
    end

    def riemann
      @riemann ||= new_riemann_client
    end
    alias :r :riemann

    def run
      t0 = Time.now
      loop do
        begin
          tick
          riemann.send_message(ok: true)
        rescue => e
          $stderr.puts "#{e.class} #{e}\n#{e.backtrace.join "\n"}"
        end

        # Sleep.
        sleep(options[:interval] - ((Time.now - t0) % options[:interval]))
      end
    end

    def tick
    end
  end
end
