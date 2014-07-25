require 'test/unit'
require 'prysless'
Pry.config.input = StringIO.new("exit\n")
class FakeSSH
    def exec!(string) end
end
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
    end
    def test_store
        Dir.mktmpdir do |dir|
            ENV['HOME'] = dir
            s = Prysless::Store.new
            s['lol'] = 'lil'
            assert s['lol'] == 'lil'
            s.test = 'blah'
            assert s.test == 'blah'
            assert s.test == s['test']
        end
    end
    def test_remote
        shell = Prysless::Shell.new
        args = {}
        shell.remote(args)
        def shell.remote(args) FakeSSH.new end
        shell.remote_shell(args)
        shell.remote_debug(args)
    end
end

