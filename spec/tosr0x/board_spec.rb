require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe TOSR0x::Board do
  let(:board) { described_class.new(RELAY_PORT, RELAY_COUNT) }

  describe '#version' do
    it 'reads the board version' do
      expect(board.version).not_to eq(nil)
    end
  end

  describe '#size' do
    it 'returns the number of relays in a board' do
      expect(board.size).to eq(8)
    end
  end

  describe '#state' do
    it 'returns an array of the same size as the number of relays in the board' do
      (1..RELAY_COUNT).each do |size|
        board = described_class.new(RELAY_PORT, size)
        expect(board.state.size).to eq(board.size)
      end
    end

    it 'returns an array of all false elements if all the relays are disabled' do
      disable(:all)
      expect(board.state).to all(eq(0))
    end

    it 'returns an array of all true elements if all the relays are enabled' do
      enable(:all)
      expect(board.state).to all(eq(1))
    end

    it 'returns an array that is true on the relays that are enabled' do
      disable(:all)
      (1..board.size).each { |index| enable(index) if index.even? }
      expect(board.state).to eq([0, 1] * (board.size / 2))
    end

    it 'returns the state for a particular relay' do
      disable(:all)
      (1..board.size).each { |index| enable(index) if index.odd? }
      (1..board.size).each { |index| expect(board.state(index)).to eq(index.odd? ? 1 : 0) }
    end
  end

  describe '#get' do
    it 'raises an error for index board size + 1' do
      expect { board.get(board.size + 1) }.to raise_error(RuntimeError)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'returns an Relay instance for indexes in the range [1, board.size]' do
      (1..board.size).each do |index|
        relay = board.get(index)
        expect(relay).not_to eq(nil)
        expect(relay).to be_an(TOSR0x::Relay)
        expect(relay.index).to eq(index)
        expect(relay.board).to eq(board)
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#enable' do
    it 'raise an error for index board.size + 1' do
      expect { board.enable(board.size + 1) }.to raise_error(RuntimeError)
    end

    (1..RELAY_COUNT).each do |index|
      it "enables the relay at index #{index}" do
        disable(index)
        board.enable(index)
        expect(board.state(index)).to eq(1)
      end
    end

    it 'enables all relays with index == 0' do
      disable(:all)
      board.enable(0)
      expect(board.state).to all(eq(1))
    end

    it 'enables all relays with index == :all' do
      disable(:all)
      board.enable(:all)
      expect(board.state).to all(eq(1))
    end

    it 'disables all relays with index == :none' do
      enable(:all)
      board.enable(:none)
      expect(board.state).to all(eq(0))
    end
  end

  describe '#disable' do
    it 'raise an error for index board.size + 1' do
      expect { board.disable(board.size + 1) }.to raise_error(RuntimeError)
    end

    (1..RELAY_COUNT).each do |index|
      it "enables the relay at index #{index}" do
        enable(index)
        board.disable(index)
        expect(board.state(index)).to eq(0)
      end
    end

    it 'disables all relays with index == 0' do
      enable(:all)
      board.disable(:all)
      expect(board.state).to all(eq(0))
    end

    it 'disables all relays with index == :all' do
      enable(:all)
      board.disable(:all)
      expect(board.state).to all(eq(0))
    end

    it 'enables all relays with index == :none' do
      disable(:all)
      board.disable(:none)
      expect(board.state).to all(eq(1))
    end
  end

  describe '#toggle' do
    before do
      disable(:all)
    end

    it 'raise an error for index board.size + 1' do
      expect { board.toggle(board.size + 1) }.to raise_error(RuntimeError)
    end

    (1..RELAY_COUNT).each do |index|
      it "toggles the relay at index #{index}" do
        enable(index) if index.even?
        board.toggle(index)
        expect(board.state(index)).to eq(index.even? ? 0 : 1)
      end
    end

    it 'toggles all the relays with index == 0' do
      (1..board.size).each { |index| enable(index) if index.odd? }
      board.toggle(0)
      expect(board.state).to eq([0, 1] * (board.size / 2))
    end

    it 'toggles all the relays with index == :all' do
      (1..board.size).each { |index| enable(index) if index.even? }
      board.toggle(:all)
      expect(board.state).to eq([1, 0] * (board.size / 2))
    end
  end
end
