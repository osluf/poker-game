require_relative '../lib/poker_hand'

RSpec.describe PokerHand do
  describe '#rank_key' do
    subject { described_class.new(hand).rank_key }

    context 'with a royal flush' do
      let(:hand) { %w[AH TH JH QH KH] }

      it { is_expected.to eq(:royal_flush) }
    end

    context 'with a straight flush' do
      context 'when a low straight flush' do
        let(:hand) { %w[4H AH 2H 3H 5H] }

        it { is_expected.to eq(:straight_flush) }
      end

      context 'when a medium straight flush' do
        let(:hand) { %w[TH 7H 9H 8H JH] }

        it { is_expected.to eq(:straight_flush) }
      end
    end

    context 'with four of a kind' do
      context 'when only numbers' do
        let(:hand) { %w[7H KC 7S 7S 7D] }

        it { is_expected.to eq(:four_of_a_kind) }
      end

      context 'when only letters' do
        let(:hand) { %w[JH KC KS KS KD] }

        it { is_expected.to eq(:four_of_a_kind) }
      end
    end

    context 'with a full house' do
      let(:hand) { %w[KH KC AS AS AD] }

      it { is_expected.to eq(:full_house) }
    end

    context 'with a flush' do
      let(:hand) { %w[9H 9H 7H 2H 3H] }

      it { is_expected.to eq(:flush) }
    end

    context 'with a straight' do
      context 'when the lowest' do
        let(:hand) { %w[2H AC 3S 4S 5D] }

        it { is_expected.to eq(:straight) }
      end

      context 'when a low one' do
        let(:hand) { %w[2H 3C 5S 4S 6D] }

        it { is_expected.to eq(:straight) }
      end
    end

    context 'with three of a kind' do
      context 'when only numbers' do
        let(:hand) { %w[5H 5C 5S 7S 6D] }

        it { is_expected.to eq(:three_of_a_kind) }
      end

      context 'when only letters' do
        let(:hand) { %w[AH AC AS JS KD] }

        it { is_expected.to eq(:three_of_a_kind) }
      end
    end
    
    context 'with two pairs' do
      context 'when only numbers' do
        let(:hand) { %w[5H 5C 6S 6S KD] }

        it { is_expected.to eq(:two_pairs) }
      end

      context 'when only letters' do
        let(:hand) { %w[JH AC AS JS KD] }

        it { is_expected.to eq(:two_pairs) }
      end
    end

    context 'with a pair' do
      context 'when only numbers' do
        let(:hand) { %w[5H 5C 6S 7S KD] }

        it { is_expected.to eq(:one_pair) }
      end

      context 'when only letters' do
        let(:hand) { %w[5H 6C KS 7S KD] }

        it { is_expected.to eq(:one_pair) }
      end
    end

    context 'with a high card' do
      context 'when it is a number' do
        let(:hand) { %w[2H 3C 4S 5S 9D] }

        it { is_expected.to eq(:high_card) }
      end

      context 'when it is a letter' do
        let(:hand) { %w[AH 5C 6S 7S KD] }

        it { is_expected.to eq(:high_card) }
      end
    end
  end

  describe '#<=>' do
    # It's mentioned all scenarios in the file have a clear winner,
    # in any case, let's test for it here.
    context 'when it is a complete tie' do
      subject { described_class.new(%w[9H 9C 7C 2H 3H]) }
      let(:other) { described_class.new(%w[3H 2C 7S 9S 9D]) }

      it { is_expected.to eq(other) }

      context 'when :royal_flush' do
        subject { described_class.new(%w[AH TH JH QH KH]) }
        let(:other) { described_class.new(%w[TH AH QH JH KH]) }

        it { is_expected.to eq(other) }
      end
    end

    context 'when there is no draw scenario' do
      context 'when "flush" vs "four of a kind"' do
        subject { described_class.new(%w[9H 9H 7H 2H 3H]) }
        let(:other) { described_class.new(%w[7H KC 7S 7S 7D]) }

        it { is_expected.to be < other }
      end
    end

    context 'when in a draw, but one hand has higher score' do
      context 'when in a :straight_flush' do
        subject { described_class.new(%w[4H AH 2H 3H 5H]) }
        let(:other) { described_class.new(%w[3H 2H 5H 4H 6H]) }

        it { is_expected.to be < other }
        it { expect(subject.rank_key).to eq(:straight_flush) }
        it { expect(other.rank_key).to eq(:straight_flush) }
      end

      context 'when in a :flush' do
        # A's high card.
        subject { described_class.new(%w[5H 4H 2H AH 9H]) }
        # There's a pair, and it should/will be ignored
        # in the untying.
        let(:other) { described_class.new(%w[3H 3H 8H 9H 4H]) }

        it { is_expected.to be > other }
        it { expect(subject.rank_key).to eq(:flush) }
        it { expect(other.rank_key).to eq(:flush) }

        context 'when opponent hand has a pair' do
          # Opponent has two A's, but it won't be considered a pair
          # in the untie.
          subject { described_class.new(%w[5H 4H 2H AH AH]) }

          # A's high card.
          let(:other) { described_class.new(%w[5H 4H 9H AH 3H]) }

          it { is_expected.to be > other }
          it { expect(subject.rank_key).to eq(:flush) }
          it { expect(other.rank_key).to eq(:flush) }
        end
      end

      context 'when in a :straight' do
        subject { described_class.new(%w[4H AD 2S 3H 5H]) }
        let(:other) { described_class.new(%w[3S 2H 5S 4H 6H]) }

        it { is_expected.to be < other }
        it { expect(subject.rank_key).to eq(:straight) }
        it { expect(other.rank_key).to eq(:straight) }
      end

      context 'when in a :full_house' do
        context 'with a higher group of 3' do
          subject { described_class.new(%w[2H 2D 4C 4D 4S]) }
          let(:other) { described_class.new(%w[3C 3D 3S 9S 9D]) }

          it { is_expected.to be > other }
          it { expect(subject.rank_key).to eq(:full_house) }
          it { expect(other.rank_key).to eq(:full_house) }
        end

        context 'with a higher group of 2' do
          subject { described_class.new(%w[9H 9D 4C 4D 4S]) }
          let(:other) { described_class.new(%w[4C 4D 4S TS TD]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:full_house) }
          it { expect(other.rank_key).to eq(:full_house) }
        end
      end

      context 'when in a :one_pair' do
        context 'with a higher pair' do
          subject { described_class.new(%w[AD 3S AH 4H 2C]) }
          let(:other) { described_class.new(%w[QD QD 3H 2D 4S]) }

          it { is_expected.to be > other }
          it { expect(subject.rank_key).to eq(:one_pair) }
          it { expect(other.rank_key).to eq(:one_pair) }
        end

        context 'with a higher kick' do
          subject { described_class.new(%w[AD 3S AH 4H 2C]) }
          let(:other) { described_class.new(%w[AD AD 3H 5D 4S]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:one_pair) }
          it { expect(other.rank_key).to eq(:one_pair) }
        end
      end

      context 'when in a :two_pairs' do
        context 'with higher 1st pair' do
          subject { described_class.new(%w[2D 3S 3H 4H 4C]) }
          let(:other) { described_class.new(%w[AD 3D 3H 2D 2S]) }

          it { is_expected.to be > other }
          it { expect(subject.rank_key).to eq(:two_pairs) }
          it { expect(other.rank_key).to eq(:two_pairs) }
        end

        context 'with higher 2nd pair' do
          subject { described_class.new(%w[QD 2S 2H 4H 4C]) }
          let(:other) { described_class.new(%w[AD 4D 4H 3D 3S]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:two_pairs) }
          it { expect(other.rank_key).to eq(:two_pairs) }
        end

        context 'with higher kick' do
          subject { described_class.new(%w[QD 3S 3H 4H 4C]) }
          let(:other) { described_class.new(%w[4D 4H 3D 3S AD]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:two_pairs) }
          it { expect(other.rank_key).to eq(:two_pairs) }
        end
      end

      context 'when in a :three_of_a_kind' do
        context 'with a higher trio' do
          subject { described_class.new(%w[5D 5S 5H 4H 9C]) }
          let(:other) { described_class.new(%w[3D 3D 3H 2D TS]) }

          it { is_expected.to be > other }
          it { expect(subject.rank_key).to eq(:three_of_a_kind) }
          it { expect(other.rank_key).to eq(:three_of_a_kind) }
        end

        context 'with a higher kick' do
          subject { described_class.new(%w[3D 3S 3H 4H 9C]) }
          let(:other) { described_class.new(%w[3D 3D 3H 2D TS]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:three_of_a_kind) }
          it { expect(other.rank_key).to eq(:three_of_a_kind) }
        end
      end

      context 'when in a :four_of_a_kind' do
        context 'with a higher 4 of a kind' do
          subject { described_class.new(%w[3D 3S 3H 3H 9C]) }
          let(:other) { described_class.new(%w[3D 4D 4H 4D 4S]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:four_of_a_kind) }
          it { expect(other.rank_key).to eq(:four_of_a_kind) }
        end

        context 'with a higher kick' do
          subject { described_class.new(%w[4D 4S 4H 4H 9C]) }
          let(:other) { described_class.new(%w[TD 4D 4H 4D 4S]) }

          it { is_expected.to be < other }
          it { expect(subject.rank_key).to eq(:four_of_a_kind) }
          it { expect(other.rank_key).to eq(:four_of_a_kind) }
        end
      end
    end

    context 'when in a draw' do
      context 'when in a :straight_flush' do
        subject { described_class.new(%w[4H AH 2H 3H 5H]) }
        let(:other) { described_class.new(%w[3H 2H 5H 4H AH]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:straight_flush) }
        it { expect(other.rank_key).to eq(:straight_flush) }
      end

      context 'when in a :flush' do
        subject { described_class.new(%w[5H 4H 2H AH 9H]) }
        let(:other) { described_class.new(%w[4H 5H 2H 9H AH]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:flush) }
        it { expect(other.rank_key).to eq(:flush) }
      end

      context 'when in a :straight' do
        subject { described_class.new(%w[4H 6D 2S 3H 5H]) }
        let(:other) { described_class.new(%w[3S 2H 5S 4H 6H]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:straight) }
        it { expect(other.rank_key).to eq(:straight) }
      end

      context 'when in a :full_house' do
        subject { described_class.new(%w[9H 9D 4C 4D 4S]) }
        let(:other) { described_class.new(%w[4C 4D 4S 9H 9D]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:full_house) }
        it { expect(other.rank_key).to eq(:full_house) }
      end

      context 'when in a :one_pair' do
        subject { described_class.new(%w[AD 3S AH 4H 2C]) }
        let(:other) { described_class.new(%w[AH 4H 2C AD 3S]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:one_pair) }
        it { expect(other.rank_key).to eq(:one_pair) }
      end

      context 'when in a :two_pairs' do
        subject { described_class.new(%w[QD 2S 2H 4H 4C]) }
        let(:other) { described_class.new(%w[4H 4C QD 2S 2H]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:two_pairs) }
        it { expect(other.rank_key).to eq(:two_pairs) }
      end

      context 'when in a :three_of_a_kind' do
        subject { described_class.new(%w[3D 3S 3H 4H 9C]) }
        let(:other) { described_class.new(%w[4H 9C 3D 3S 3H]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:three_of_a_kind) }
        it { expect(other.rank_key).to eq(:three_of_a_kind) }
      end

      context 'when in a :four_of_a_kind' do
        subject { described_class.new(%w[4D 4S 4H 4H 9C]) }
        let(:other) { described_class.new(%w[4H 9C 4D 4S 4H]) }

        it { is_expected.to eq(other) }
        it { expect(subject.rank_key).to eq(:four_of_a_kind) }
        it { expect(other.rank_key).to eq(:four_of_a_kind) }
      end
    end
  end
end
