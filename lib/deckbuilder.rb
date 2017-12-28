
class DeckBuilder
  def initialize(path_to_deck)
    @initial_deck = load_from_file(path_to_deck)
    @deck = [@initial_deck]
    @discard = []
  end

  # @TODO move to DAO, pass in json
  def load_from_file(path_to_deck)
    # One entry per card, this makes removal easier
    temp_deck = JSON.parse(File.read(path_to_deck))
    out_deck = []
    temp_deck.each do |card|
      trimmed_card = card.clone
      trimmed_card.delete("quantity")
      quantity = card["quantity"].to_i
      quantity.times { out_deck.push(trimmed_card.clone) }
    end
    out_deck
  end

  # @TODO move to DAO, add toJson method
  def save(pathToFile) 
    #Collapse changes and save as json.
    # build a json collapser
  end

  def possible_draws_grouped(number_of_draws)
    raise CardCounterError::IllegalArgument.new("Number Of Draws must be non-negative") if (number_of_draws < 0)
    raise CardCounterError::IllegalArgument.new("Number of draws exceeds deck size") if (number_of_draws >= deck_length)
    return [] if(number_of_draws == 0)
    out_collection = [top_deck_spy]
    return out_collection if(number_of_draws <= top_deck_spy.length)
    out_collection_length = out_collection[0].length
    cursor = @deck.length - 2 # one before top_deck
    while(out_collection_length < number_of_draws) do
      next_adder = @deck[cursor]
      out_collection_length += next_adder.length
      out_collection.unshift(next_adder.clone)
      cursor -= 1
    end
    return out_collection
  end

  def move_to_discard(move_token)
    last_deck = @deck.last
    removed_card = delete_first(last_deck, move_token)
    @deck.pop if(last_deck.length == 0)
    @discard.push removed_card
  end

  def move_from_bottom_to_discard(move_token)
    bottom_deck = @deck.first
    removed_card = delete_first(bottom_deck, move_token)
    @discard.push removed_card
  end

  def add_discard_to_deck
    @deck.push(@discard) if(@discard.length > 0)
    @discard = []
  end

  def discard_spy
    @discard.clone
  end

  def deck_stack_depth_spy
    @deck.length
  end

  def bottom_deck_spy
    @deck.first.clone
  end

  def top_deck_spy
    @deck.last.clone
  end

  def full_deck_spy
    @deck.clone
  end

  private

  def delete_first(deck, item_token)
    deck.each_with_index do |deck_item, i|
      return deck.delete_at(i) if(deck_item["displayToken"] == item_token)
    end
    raise CardCounterError::TokenNotFound.new("Attempted to remove #{item_token} did not discover it in deck array")
  end

  def deck_length
    out_length = 0
    @deck.each { |sub_deck| out_length += sub_deck.length }
    out_length
  end
end
