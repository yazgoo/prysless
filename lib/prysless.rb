require "prysless/version"
require 'pry'
require 'pstore'
require 'fileutils'
require 'net/ssh'
# Public: Utilities to make ruby object accessible via pry
#
# Examples
#
#   Prysless::Shell.new
module Prysless
    # Public: Pry store allowing to pass and persist data between sessions
    #   Data can be accessed either via hash notation or metheod notation
    #   This is a core functionality of prysless since we want to be able
    #   to share states with other processes (namely: the shell) without
    #   copy/paste.
    #
    # Examples
    #
    #   Store.new['lol'] = 'test'
    #   Store.new['lol]
    #       => 'test'
    #   Store.new.lil = 'blah'
    #   Store.new.lil
    #       => 'blah'
    class Store
        def initialize
            configuration_directory = "#{ENV['HOME']}/.config"
            FileUtils.mkdir_p configuration_directory
            @store = PStore.new("#{configuration_directory}/prysless.pstore")
        end
        # Public: saves data to the store
        #
        # key   - the name of the key to store
        # value - the value associated with the key
        #
        # Examples
        #
        #   []= 'lol', 'test'
        #       => 'test'
        #  
        # Returns the data that was saved
        def []= key, value
            @store.transaction { @store[key] = value }
        end
        # Public: reads data from the store
        #
        # key - the value of the key to retrieve
        #
        # Examples
        #
        #   []= 'lol'
        #       => 'test'
        #  
        # Returns the data to read
        def [] key
            @store.transaction { @store[key] }
        end
private
# Internal: either writes or read data to/from the store
#
# Examples
#
#   method_missing :blah=, ['test'] # writes data
#       => 'test'
#   method_missing :blah # reads data
#       => 'test'
#  
# Return the data that was saved or read
def method_missing method, *params, &block
    method = method.to_s
    if method[-1..-1] == '='
        self[method[0..-2]] = params[0]
    else
        self[method]
    end
end
    end
    # Public: Pry shell allowing to use user defined objects, based on two variables:
    #   * PRYSLESS_LIBRARY_PATH: path to load additional libraries, ":"-separated
    #   * PRYSLESS_REQUIRE: variable definitions
    #   * PRYSLESS_ALIASES: shell command aliases
    #
    # Examples
    #
    #   ENV['PRYSLESS_REQUIRE'] = "e=ec2l/Ec2l/Client.new:a=pry/[]"
    #   Shell.new
    #   # will load an ec2l client in variable e and a new array in variable a
    #
    class Shell
        def initialize
            load_objects
            shell
        end
        # Public: opens a remote secure shell (via SSH) to an host
        #
        # args - hash with arguments for the connection, see romote
        #
        # Examples
        #
        #   remote_shell '10.0.0.1'
        #       > pwd
        #       ["/root"]
        #
        def remote_shell args
            remote(args) do |ssh|
                command = true
                while command
                    print "> "
                    command = gets
                    if command
                        result = ssh.exec! command
                        puts result.split("\n").awesome_inspect if not result.nil?
                    end
                end
                ssh.exec! "exit"
            end
        end
        # Public: opens a remote-pry debugging session over SSH
        #
        # args - hash with arguments for the connection, see romote
        #
        def remote_debug args
            require 'pry-remote'
            remote(args) do |ssh|
                ssh.forward.local 9876, '127.0.0.1', 9876
                ssh.forward.remote 9877, '127.0.0.1', 9877
                debugging = true
                Thread.new { ssh.loop { debugging } }
                PryRemote::CLI.new(['-P', '9877']).run
                debugging = false
            end
        end
        private
        def shell() binding.pry end
        def var name
            value = ENV["PRYSLESS_#{name}"]
            value = if value == nil then [] else value.split(":") end
            value.each { |p| yield p }
        end
        def load_objects
            @a = {}
            @aliases = {}
            var('ALIASES') { |a| k, v = a.split('=', 2); @aliases[k] = v }
            var('LIBRARY_PATH') { |p| $LOAD_PATH << p }
            var('REQUIRE') do |p|
                name , value = p.split("=", 2)
                gem, object = value.split("/", 2)
                require gem
                @a[name] = eval(object.gsub("/", "::"))
            end
            @a['s'] = Store.new
        end
        # Internal: try and find user defined variable named with the method
        #   if its result is nil, super
        #
        # Examples
        #
        #  h
        #  NameError: undefined local variable or method `h' for #<Prysless::Shell:0x000000019f1c20>
        #  from .../lib/prysless.rb:45:in `method_missing'
        #
        #  a # with PRYSLESS_REQUIRE="a=pry/[]"
        #  => []
        #    
        # Return the declared variable from PRYSLESS_REQUIRE or calls super
        def method_missing method, *params, &block
            meth = method.to_s
            if @a[meth] then @a[meth]
            else
                meth = @aliases[meth] if @aliases[meth]
                `#{([meth] + params).join " "}`.split("\n")
            end
        end
        def remote args
            args[:user] = 'root' if not args[:user]
            args[:keys] = Dir["#{ENV['HOME']}/.ssh/*.pem"]
            p args
            Net::SSH.start args.delete(:host), 
                args.delete(:user), args do |ssh|
                puts "connected"
                yield ssh
            end
        end
    end
end
