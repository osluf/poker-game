require_relative '../lib/poker_match'

RSpec.describe PokerMatch do
  describe '.print_summary' do
    subject { described_class.print_summary }

    it do
      expect { subject }.to output(
        <<~OUTPUT
          ---
          Player 1 wins: 376
          Player 2 wins: 624
          Draws: 0
          ---
        OUTPUT
      ).to_stdout
    end
  end

  # The hand comparison logic is tested in further detail at poker_hand_spec.rb
  describe '#result' do
    subject { described_class.new(hand1, hand2).result }

    context 'when it is a complete draw' do
      let(:hand1) { PokerHand.new(%w[9H 9C 7C 2H 3H]) }
      let(:hand2) { PokerHand.new(%w[3H 2C 7S 9S 9D]) }

      it { is_expected.to eq(winner: nil, rank: :draw) }
    end

    context 'when player 1 wins' do
      let(:hand1) { PokerHand.new(%w[5H 4H 2H AH 9H]) }
      let(:hand2) { PokerHand.new(%w[3H 3H 8H 9H 4H]) }

      it { is_expected.to eq(winner: 1, rank: :flush) }
    end

    context 'when player 2 wins' do
      let(:hand1) { PokerHand.new(%w[4H AD 2S 3H 5H]) }
      let(:hand2) { PokerHand.new(%w[3S 2H 5S 4H 6H]) }

      it { is_expected.to eq(winner: 2, rank: :straight) }
    end
  end
end
