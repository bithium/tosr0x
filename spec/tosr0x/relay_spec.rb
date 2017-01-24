require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe TOSR0x::Relay do
  let(:index) { 1 + Random.rand(board.size - 1) }
  let(:board) { TOSR0x::Board.new(RELAY_PORT, RELAY_COUNT) }
  let(:relay) { board.get(index) }

  before do
    disable(:all)
  end

  describe '#state' do
    it 'returns false when the relay is disabled' do
      disable(index)
      expect(relay.state).to eq(0)
    end
    it 'returns true when the relay is enabled' do
      enable(index)
      expect(relay.state).to eq(1)
    end
  end

  describe '#enable' do
    it 'enables the relay' do
      disable(index)
      relay.enable
      expect(relay.enabled?). to be_truthy
    end
  end

  describe '#enabled?' do
    it 'returns true if the relay is enabled' do
      enable(index)
      expect(relay.enabled?). to be_truthy
    end
    it 'returns false if the relay is disabled' do
      disable(index)
      expect(relay.enabled?). to be_falsey
    end
  end

  describe '#disable' do
    it 'disables the relay' do
      enable(index)
      relay.disable
      expect(relay.disabled?). to be_truthy
    end
  end

  describe '#disabled?' do
    it 'returns false if the relay is enabled' do
      enable(index)
      expect(relay.disabled?). to be_falsey
    end
    it 'returns true if the relay is disabled' do
      disable(index)
      expect(relay.disabled?). to be_truthy
    end
  end

  describe '#toggle' do
    it 'disables the relay if it is enabled' do
      enable(index)
      relay.toggle
      expect(relay.enabled?). to be_falsey
    end

    it 'enables the relay if it is disabled' do
      disable(index)
      relay.toggle
      expect(relay.enabled?). to be_truthy
    end
  end
end
