


class DeckBuilder
  def initialize(path_to_deck)
    @initial_deck = load_from_file(path_to_deck)
    @deck = [@initial_deck]
    @discard = []
  end

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

  def save(pathToFile) 
    #Collapse changes and save as json.

  end

  def possible_draws

  end

  def move_to_discard(move_token)
    last_deck = @deck.last
    removed_card = delete_first(last_deck, move_token)
    @deck.pop if(last_deck.length == 0)
    @discard.push removed_card
  end

  def discard_spy
    @discard.clone
  end

  # What's left of starting deck is always @ 0
  def bottom_deck_spy
    @deck.first.clone
  end

  private

  def delete_first(deck, item_token)
    deck.each_with_index do |deck_item, i|
      return deck.delete_at(i) if(deck_item["displayToken"] == item_token)
    end
    raise Error # @TODO Name errors, this one happens because we tried to delete a card that wasn't in the top deck
  end
end
