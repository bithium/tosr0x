$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tosr0x'

RELAY_COUNT = ENV['RELAY_COUNT'] || 8
RELAY_PORT  = ENV['RELAY_PORT'] || '/dev/ttyUSB0'

# Helper methods for the Unit testing
module Helpers

  # Return the serialport for the board for the current spec
  #
  # @returns [SerialPort] the SerialPort instance associated with the current +board+
  def serialport
    board.port
  end

  # Enable a specific relay on the board under testing.
  #
  # @warning this function requires an method to be called +serialport+ to exist to
  # provide the SerialPort object to write to.
  #
  # @param index [Integer, :all]  index of the relay to enable.
  #                               The value 0/:all will enable +all+ relays.
  def enable(index)
    index = 0 if index == :all
    serialport.write((TOSR0x::COMMANDS[:all].ord + index).chr('UTF-8'))
    sleep(0.1)
  end

  # Disable a specific relay on the board under testing.
  #
  # @warning this function requires an method to be called +serialport+ to exist to
  # provide the SerialPort object to write to.
  #
  # @param index [Integer, :all]  index of the relay to disable.
  #                               The value 0/:all will enable +all+ relays.
  def disable(index)
    index = 0 if index == :all
    serialport.write((TOSR0x::COMMANDS[:none].ord + index).chr('UTF-8'))
    sleep(0.1)
  end

end

RSpec.configure do |config|
  config.include Helpers
end
