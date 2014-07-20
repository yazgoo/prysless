begin
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
rescue SyntaxError => e
    p e
rescue LoadError => e
    p e
rescue Exception => e
    p e
end
require 'test/unit'
require 'prysless'
Pry.config.input = StringIO.new("exit\n")
class PryslessTest < Test::Unit::TestCase
    def test_run
        ENV['PRYSLESS_LIBRARY_PATH'] = "/tmp:/"
        ENV['PRYSLESS_REQUIRE'] = "a=pry/[]:b=pry/{}"
        shell = Prysless::Shell.new
        assert shell.a == []
        assert shell.b == {}
        x = nil
        begin
            shell.help
        rescue Exception => e
            x = e
        end
        assert_not_nil e
    end
end

