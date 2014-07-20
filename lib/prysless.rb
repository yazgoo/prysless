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
            value = ENV[name]
            value = if value == nil then [] else value.split(":") end
            value.each { |p| yield p }
        end
        def load_objects
            @a = {}
            var('PRYSLESS_LIBRARY_PATH') { |p| $LOAD_PATH << p }
            var('PRYSLESS_REQUIRE') do |p|
                name , value = p.split("=", 2)
                gem, object = value.split("/", 2)
                require gem
                @a[name] = eval(object.gsub("/", "::"))
            end
        end
        def method_missing method, *params, &block
            if @a[method.to_s]
                @a[method.to_s]
            else
                super
            end
        end
    end
end
