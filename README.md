# Prysless

[![Build Status](https://travis-ci.org/yazgoo/prysless.svg?branch=master)](https://travis-ci.org/yazgoo/prysless)
[![Test Coverage](https://codeclimate.com/github/yazgoo/prysless/coverage.png)](https://codeclimate.com/github/yazgoo/prysless)
[![Code Climate](https://codeclimate.com/github/yazgoo/prysless.png)](https://codeclimate.com/github/yazgoo/prysless)
[![Inline docs](http://inch-ci.org/github/yazgoo/prysless.png?branch=master)](http://inch-ci.org/github/yazgoo/prysless)
[![Gem Version](https://badge.fury.io/rb/prysless.svg)](http://badge.fury.io/rb/prysless)

prysless aims to integrate ruby programs in terminal sessions with lowest harm.
It is based pry REPL, hence the name.

## Installation

Add this line to your application's Gemfile:

    gem 'prysless'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prysless

## Configuring

All the configuring is done via environment variables,
so to me it adds up to editing my bashrc

    *  PRYSLESS\_LIBRARY\_PATH: path to load additional libraries, ":"-separated
    *  PRYSLESS\_REQUIRE: variable definitions
    *  PRYSLESS\_ALIASES: shell command aliases

For example:

    export PRYSLESS_ALIASES='l=ls:c=cd'
    export PRYSLESS_LIBRARY_PATH="$HOME/dev/ec2l/lib"
    export PRYSLESS_REQUIRE="e=ec2l/Ec2l/Client.new:a=pry/[]"

PRYSLESS\_REQUIRE tells prysless what objects to preload and how to name them
So, for example:

    e=ec2l/Ec2l/Client.new

Will load into the variable named e Ec2l::Client.new after requiring 'ec2l'
Because I use the development version of ec2l and not the gem directly,
I added my ec2l development library directory to PRYSLESS\_LIBRARY\_PATH

Also, I like to add an aliases to prysless\_store command:

    alias p=prysless_store

## Using

Just run
    
    prysless

Once in pry shell, you'll be able to access the variables you defined:

```ruby
[1] pry(<Prysless::Shell>)> e
=> <Ec2l::Client:0x000000022f5e70
...
[2] pry(<Prysless::Shell>)> cd e

[4] pry(<Ec2l::Client>):1> show-doc ins
```

Lets say you need to share data between your session and an external program:

```ruby
[8] pry(#<Prysless::Shell>)> s.blah = 'test'
=> "test"
```

Now on your shell, provided 'p' is an alias to prysless\_store:

    $ echo I need to $(p blah) some more
    I need to test some more

## Contributing

1. Fork it ( https://github.com/[my-github-username]/prysless/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
