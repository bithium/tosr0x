require 'tosr0x/version'

require 'serialport'

# Top level module for the tosr0x gem.
module TOSR0x

  # Base commands to be sent to the board.
  COMMANDS = {
    version: 'Z',
    state:   '[',
    all:     'd',
    none:    'n'
  }.freeze

  # This class represents a TOSR0x relay board.
  class Board

    # Serial port the relay board is connected to.
    attr_reader :port

    # Number of relays in the board.
    attr_reader :size

    # Board initialization
    #
    # @param port [String]  serial port path for the board.
    # @param size [Integer] number of relays in the board.
    def initialize(port, size)
      @port = SerialPort.new(port, 9600)
      @size = size
      @relays = (0..size).to_a.map { |index| Relay.new(self, index) }
      @relays.freeze
    end

    # Read the version information from the board.
    #
    # @return [String] two bytes version information.
    def version
      cmd(COMMANDS[:version], 2)
    end

    # Retrieve the state for the given relay.
    #
    # @param index [Integer, :all] relay index to get the state for.
    #
    # @return [Integer]        0 if relay is disabled or 1 if enabled.
    # @return [Array<Integer>] with the states for all the relays.
    def state(index = :all)
      index = check_index(index)
      res = cmd(COMMANDS[:state]).ord
      res = (0...size).to_a.map { |pos| (res & (0x01 << pos)) >> pos }
      res = res[index - 1] if index && index.nonzero?
      res
    end

    # Get the an Relay instance that can control the relay at the given +index+.
    #
    # @param index [Integer, :all] relay index to get the instance for.
    #
    # @return [Relay]        instance for the given index.
    # @return [Array<Relay>] an array with all the relays.
    def get(index = :all)
      return @relays[1..-1] if index == :all
      index = check_index(index)
      @relays[index]
    end

    # Enable the relay at the given index.
    #
    # @param index [Integer, :all, :none] the index of the relay to enable [1 - size].
    #   - _:all_  - enable all relays.
    #   - _:none_ - disable all relays.
    def enable(index)
      return disable(:all) if index == :none
      index = check_index(index)
      relay = @relays[index]
      relay.enable
    end

    # Check if the relay at the given +index+ is enabled.
    #
    # @param index [Integer] the index the check the state for.
    #
    # @return [Boolean] +true+ if relay is enabled, +false+ otherwise.
    def enabled?(index)
      index = check_index(index)
      relay = @relays[index]
      relay.enabled?
    end

    # Disable the relay at the given index.
    #
    # @param index [Integer, :all, :none] the index of the relay to enable [1 - size].
    #   - _:all_  - disable all relays.
    #   - _:none_ - enable all relays.
    def disable(index)
      return enable(:all) if index == :none
      index = check_index(index)
      relay = @relays[index]
      relay.disable
    end

    # Check if the relay at the given +index+ is disabled.
    #
    # @param index [Integer] the index the check the state for.
    #
    # @return [Boolean] +true+ if relay is disabled, +false+ otherwise.
    def disabled?(index)
      index = check_index(index)
      relay = @relays[index]
      relay.disabled?
    end

    # Toggle the relay state at the given index.
    #
    # @param index [Integer, :all] the index of the relay to toggle [1 - size].
    #   - _:all_ - toggle all relays.
    def toggle(index)
      index = check_index(index)
      if index.nonzero?
        relay = @relays[index]
        relay.toggle
      else
        @relays[1..-1].map(&:toggle)
      end
    end

    protected

    def cmd(out, count = 1)
      Timeout.timeout(1) do
        @port.write(out)
        @port.read(count)
      end
    end

    private

    # Check +index+ is valid.
    #
    # @param index [Integer] the index to check it is between [0, size]
    def check_index(index)
      index = 0 if index == :all
      index = index.to_i
      raise "Invalid index #{index}, valid values [1 - #{size}]" \
        if index.is_a?(Integer) && index > size
      index
    end

  end

  # This class represents a relay in the TOSR0x board.
  class Relay

    # Index of the relay in the board.
    attr_reader :index

    # Board this relay belongs to
    attr_reader :board

    # Initialize the relay.
    #
    # @param board [Board]   the board this relay belongs to.
    # @param index [Integer] the index this relay is at in the board.
    def initialize(board, index)
      check_index(board, index)
      @index = index
      @board = board
    end

    # Retrieve the state for the relay.
    #
    # @return [Integer] +1+ if the relay is enabled, +0+ otherwise.
    def state
      board.state(index)
    end

    # Enable the relay.
    def enable
      board.port.write((COMMANDS[:all].ord + index).chr('UTF-8'))
    end

    # Check is the relay is enabled.
    def enabled?
      state.nonzero?
    end

    # Disable the relay.
    def disable
      board.port.write((COMMANDS[:none].ord + index).chr('UTF-8'))
    end

    # Check is the relay is disabled.
    def disabled?
      state.zero?
    end

    # Toggle the relay state.
    def toggle
      return enabled? ? disable : enable if index.nonzero?
      board.toggle(:all)
    end

    private

    # Check the index is correct.
    #
    # @param board [Board]   the board the relay belongs to.
    # @param index [Integer] the position of the relay is on the board.
    def check_index(board, index)
      index = index.to_i
      raise "Invalid index for relay : #{index}, valid values [0-#{board.size}]" \
        if index > board.size
    end

  end

end
