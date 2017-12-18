


class DeckBuilder
  def initialize(path_to_deck)
    @initial_deck = load_from_file(path_to_deck)
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

end
