require 'tosr0x/version'

require 'serialport'
require 'observer'

module TOSR0x

  COMMANDS = {
    version: 'Z',
    state:   '[',
    all:     'd',
    none:    'n'
  }.freeze

  # This class represents a TOSR0x board.
  class Board

    # Serial port the relay board is connected to.
    attr_reader :port

    # Number of relays in the board.
    attr_reader :size

    def initialize(port, size)
      @port = SerialPort.new(port, 9600)
      @size = size
      @relays = (0..size).to_a.map { |index| Relay.new(self, index) }
      @relays.freeze
    end

    def version
      @port.write(COMMANDS[:version])
      @port.read(2)
    end

    def state(index = nil)
      index = check_index(index)
      @port.write(COMMANDS[:state])
      res = @port.read(1).ord
      res = (0...size).to_a.map { |pos| (res & (0x01 << pos)) >> pos }
      res = res[index - 1] if index && index.nonzero?
      res
    end

    def get(index = :all)
      return @relays if index == :all
      index = check_index(index)
      @relays[index]
    end

    def enable(index)
      return disable(:all) if index == :none
      index = check_index(index)
      relay = @relays[index]
      relay.enable
    end

    def enabled?(index)
      index = check_index(index)
      relay = @relays[index]
      relay.enabled?
    end

    def disable(index)
      return enable(:all) if index == :none
      index = check_index(index)
      relay = @relays[index]
      relay.disable
    end

    def disabled?(index)
      index = check_index(index)
      relay = @relays[index]
      relay.disabled?
    end

    def toggle(index)
      index = check_index(index)
      if index.nonzero?
        relay = @relays[index]
        relay.toggle
      else
        @relays[1..-1].map(&:toggle)
      end
    end

    private

    def check_index(index)
      if index.is_a?(Integer)
        raise "Invalid index #{index}, valid values [1 - #{size}]" if index > size
      elsif index.is_a?(Symbol)
        raise "Invalid index #{index}, valid values[:all]" if index != :all
        index = 0
      end
      index
    end

  end

  # This class represents a relay in the TOSR0x board.
  class Relay

    # Index of the relay in the board.
    attr_reader :index

    # Board this relay belongs to
    attr_reader :board

    def initialize(board, index)
      check_index(board, index)
      @index = index
      @board = board
    end

    def state
      board.state(index)
    end

    def enable
      board.port.write((COMMANDS[:all].ord + index).chr('UTF-8'))
    end

    def enabled?
      state.nonzero?
    end

    def disable
      board.port.write((COMMANDS[:none].ord + index).chr('UTF-8'))
    end

    def disabled?
      state.zero?
    end

    def toggle
      return enabled? ? disable : enable if index.nonzero?
      board.toggle(:all)
    end

    private

    def check_index(board, index)
      raise "Invalid index for relay : #{index}, valid values [0-#{board.size}]" \
        if index > board.size
    end

  end

end
