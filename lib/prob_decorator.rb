

class ProbDecorator
  def initialize(full_deck)
    @deck = deep_clone(full_deck)
  end

  def decorate(number_of_draws)
    draw_index = Label::DRAW_PROB_PREFIX + number_of_draws.to_s
    draws_left = number_of_draws
    running_count = 0
    @deck.reverse.each do |sub_deck|
      sub_deck_count = count_deck(sub_deck)
      sub_deck.each do |card|
        card[draw_index] = probability_in(draws_left, card[Label::QUANTITY].to_f, sub_deck_count).round 4
      end
      draws_left = draws_left - sub_deck.length
      running_count += sub_deck_count
      break if running_count >= number_of_draws
    end
  end

  def decorate_at_least(draws=0, at_least=0) 
    draw_index = label_at_least(draws, at_least)
    @deck.reverse.each do |sub_deck|
      sub_deck_count = count_deck(sub_deck)
      sub_deck.each do |card|
        card[draw_index] = 0.0
      end
    end
  end

  def full_deck
    return @deck
  end

  private

  def count_deck(deck)
    running_total = 0
    deck.each do |card|
      running_total += card[Label::QUANTITY]
    end
    running_total
  end

  def calc_denominator(number_of_draws, card_quantity, sub_deck_count)
    not_this_card = sub_deck_count - card_quantity
    raise CardCounterError::ImpossibleNumber.new("Not card is negative. How?") if not_this_card < 0
    raise CardCounterError::IllegalArgument.new("Number of draws cannot exceed deck quantity for denominator") if number_of_draws > sub_deck_count
    running_denom = not_this_card
    (number_of_draws - 1).times do
      not_this_card -= 1
      running_denom *= not_this_card
    end
    running_denom
  end

  def calc_numerator(number_of_draws, sub_deck_count)
    deck_count = sub_deck_count
    raise CardCounterError::IllegalArgument.new("Number of draws cannot exceed deck quantity") if number_of_draws > sub_deck_count
    running_numerator = deck_count
    (number_of_draws - 1).times do
      deck_count -= 1
      running_numerator *= deck_count
    end
    running_numerator
  end

  def probability_in(number_of_draws, card_quantity, sub_deck_count)
    return 1 if(number_of_draws >= sub_deck_count)
    return 1 if(card_quantity == sub_deck_count)
    return 0 if(card_quantity == 0)
    return 0 if(number_of_draws == 0)
    denominator = calc_denominator(number_of_draws, card_quantity, sub_deck_count)
    numerator = calc_numerator(number_of_draws, sub_deck_count)
    1.0 - (denominator.to_f / numerator)
  end

  def deep_clone(deck)
    out_deck = []
    deck.each do |sub_deck|
      new_sub = []
      sub_deck.each { |card| new_sub.push keep_only_undecorated_keys(card) }
      out_deck.push sub_deck
    end
  end

  def keep_only_undecorated_keys(card)
    copy_keys = [Label::QUANTITY, Label::DISPLAY_TOKEN, Label::DISPLAY_OPTION]
    new_card = {}
    copy_keys.each { |key| new_card[key] == card[key] }
    new_card
  end

  def label_at_least(draws, at_least)
    "" + Label::DRAW_PROB_PREFIX + draws.to_s + Label::DRAW_AT_LEAST_MIDFIX + at_least.to_s
  end
end
