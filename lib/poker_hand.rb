# frozen_string_literal: true

# PokerHand represents a hand in poker containing 5 cards.
#
# It holds the logic to compare itself with other PokerHand objects
# to check which one is the winner.
#
# Example:
#
#     flush = PokerHand.new(%w[9H 9H 7H 2H 3H])
#     four_of_a_kind = PokerHand.new(%w[7H KC 7S 7S 7D])
#     four_of_a_kind > flush
#     => true
#
# It also considers tie rank situations, like two Full Houses, but one having
# higher power than another.
#
#     full_house = PokerHand.new(%w[9H 9D 4C 4D 4S])
#     higher_full_house = PokerHand.new(%w[4C 4D 4S TS TD])
#     higher_full_house > full_house
#     => true
#
# As well as a complete tie game:
#
#     straight_flush = PokerHand.new(%w[4H AH 2H 3H 5H])
#     same_straight_flush = PokerHand.new(%w[3H 2H 5H 4H AH])
#     straight_flush == same_straight_flush
#     => true
#
# TODO: This class doesn't handle memoization at all, which is a fine way of
# improving performance. Personally I'd rather do it based on data/timings,
# instead tossing @var's everywhere (though time's of the essence for the
# challenge).
# Also, note that less array/hash iterations could be made,
# with the price of having less readable code.
#
class PokerHand
  include Comparable

  ALL_CARD_VALUES = {
    **(2..9).map.to_h { [_1.to_s, _1] },
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14
  }.freeze

  RANKS = {
    royal_flush: 10,
    straight_flush: 9,
    four_of_a_kind: 8,
    full_house: 7,
    flush: 6,
    straight: 5,
    three_of_a_kind: 4,
    two_pairs: 3,
    one_pair: 2,
    high_card: 1
  }.freeze

  def initialize(hand)
    @hand = hand.map { _1.split('') }.sort_by(&:first)
  end

  # This method officially make PokerHand objects comparable/sortable,
  #
  # It considers a hand can have a higher rank than another, and also
  # figures out how to "untie" same rank situations (like two flushes,
  # or two fullhouses, etc).
  def <=>(other)
    result = rank_number <=> other.rank_number

    # Non-zero means we have a winner (1 left, -1 right).
    return result unless result.zero?

    # Untie: The first side to win the comparison is the winner
    # in an "untie" situation. If there's still no winner, it's
    # a complete tie (in real poker, winners would split the pot).
    untie_group.zip(other.untie_group).each do |n1, n2|
      return 1 if n1 > n2
      return -1 if n2 > n1
    end

    0
  end

  # In tie scenarios, i.e. hands have the same rank, it needs to make
  # the "untie" comparison in steps (see #<=>). For instance:
  #
  # - In a Full House (e.g. 2 2 2 5 5), the group of "3" takes precedence.
  #   Therefore this method will return [2, 5].
  #
  # - In a Two Pairs scenario (e.g. 2 2 3 3 5), the strongest pair wins,
  #   but there might still be room for a subsequent tie, therefore this
  #   method will return [3, 2, 5], where 5 is a called a "kick" card,
  #   which is still relevant for the "untie".
  #
  # - In a Three of a kind, or a One pair, or a Four of a kind (e.g. 4 4 4 5 6),
  #   the same logic follows, it returns [4, 6, 5], where 6 and 5 are the "kicks".
  #
  # - In a Straight, or a Flush, or a Straight flush, all card values will be
  #   returned, from highest to lowest, with no particular grouping.
  def untie_group
    values = card_values.reverse

    # Don't bother with any grouping logic if it's either a Straight (any of them),
    # or Flush. It's just not needed for checking which card is higher (see comments).
    return values if straight? || flush?

    values
      .group_by { |c| values.count(c) }
      .sort_by { |k, _| -k }
      .flat_map { |_, v| v }
      .uniq
  end

  def rank_number
    RANKS.fetch(rank_key)
  end

  def rank_key
    if royal_flush?
      :royal_flush
    elsif flush? && straight?
      :straight_flush
    elsif repeats_n_times?(4)
      :four_of_a_kind
    elsif repeats_n_times?(3) && repeats_n_times?(2)
      :full_house
    elsif flush?
      :flush
    elsif straight?
      :straight
    elsif repeats_n_times?(3)
      :three_of_a_kind
    elsif two_pairs?
      :two_pairs
    elsif repeats_n_times?(2)
      :one_pair
    else
      :high_card
    end
  end

  private

  def royal_flush?
    flush? && card_values == (10..14).to_a
  end

  def straight?
    values = card_values

    (values.min..values.max).to_a == values
  end

  def flush?
    @hand.uniq(&:last).one?
  end

  def two_pairs?
    number_repetitions.values.count { _1 == 2 } == 2
  end

  def repeats_n_times?(times)
    number_repetitions.values.include?(times)
  end

  def card_values
    card_match_values =
      # There's no scenario that A is valued 1 other than in a lowest straight.
      if (@hand.map(&:first) & %w[A 2 3 4 5]).size == 5
        { **ALL_CARD_VALUES, 'A' => 1 }
      else
        ALL_CARD_VALUES
      end

    @hand.map { card_match_values.fetch(_1.first) }.sort
  end

  def number_repetitions
    @hand.group_by(&:first).transform_values(&:size)
  end
end
