require_relative 'poker_hand'

# PokerMatch is the class that ties together a "poker match", taking two
# PokerHand's and comparing then to see which one is the winner.
# Here we also do the main challange, which is printing the winner summary,
# through the print_summary method.
#
class PokerMatch
  # Reads the poker.txt file and prints the summary of winners.
  def self.print_summary
    file = File.open('lib/poker.txt')
    score = { 1 => 0, 2 => 0, draw: 0 }

    file.readlines.each do |hands_line|
      hands = hands_line.split(' ')
      res = new(PokerHand.new(hands[0..4]), PokerHand.new(hands[5..])).result

      res[:draw] ? score[:draw] += 1 : score[res[:winner]] += 1
    end

    puts '---'
    puts "Player 1 wins: #{score[1]}"
    puts "Player 2 wins: #{score[2]}"
    puts "Draws: #{score[:draw]}"
    puts '---'
  end

  def initialize(hand1, hand2)
    @hand1 = hand1
    @hand2 = hand2
  end

  def result
    if @hand1 > @hand2
      { winner: 1, rank: @hand1.rank_key }
    elsif @hand1 < @hand2
      { winner: 2, rank: @hand2.rank_key }
    else
      { winner: nil, rank: :draw }
    end
  end
end
