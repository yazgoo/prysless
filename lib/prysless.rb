require "prysless/version"
require 'pry'
# Public: Utilities to make ruby object accessible via pry
#
# Examples
#
#   Prysless::Shell.new
module Prysless
    # Public: Pry shell allowing to use user defined objects, based on two variables:
    #   * PRYSLESS_LIBRARY_PATH: path to load additional libraries, ":"-separated
    #   * PRYSLESS_REQUIRE: variable definitions
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
    end
end
