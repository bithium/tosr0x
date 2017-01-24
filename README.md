# TOSR0x

This gem provides an API to interact with the [TOSR0x relays](http://www.tinyosshop.com/index.php?route=product/category&path=141_142) sold by the [TinySine](http://www.tinyosshop.com/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tosr0x'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tosr0x

## Usage

Please the following code for an example on using this gem.

```ruby
require 'tosr0x'

RELAY_PORT  = '/dev/ttyUSB0' # Change this to the serial port that belongs to the relay.
RELAY_COUNT = 8              # Change this to indicate the number of relays in the board.

board = TOSR0x::Board.new(RELAY_PORT, RELAY_COUNT)

# Enable all relays

board.enable(:all)   # or
board.enable(0)      # or
board.disable(:none)

# Disable all relays

board.disable(:all)   # or
board.disable(0)      # or
board.enable(:none)

# We can also enable individual relays
relay = board.get(1)

relay.enable     # or
board.enable(1)

# ... disable individual relays
relay.disable     # or
board.disable(1)

# ... and even toggle them
relay.toggle     # or
board.toggle(1)
```

For more options please see the documentation generate by [YARD](http://yardoc.org/).

## Development

Use the normal flow when using [Bundler](http://bundler.io/) and [RSpec](http://rspec.info/).

Also the guidelines from [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bithium/tosr0x.

## License

MIT (see [LICENSE](./file.LICENSE.html))

