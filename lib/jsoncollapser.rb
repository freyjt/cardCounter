class JsonCollapser
  # @TODO move these to a module
  TOKEN_LABEL = "displayToken"

  def decollapse(json_string)
    # One entry per card, this makes removal easier
    temp_deck = JSON.parse(json_string)
    out_deck = []
    temp_deck.each do |card|
      trimmed_card = card.clone
      trimmed_card.delete(Label::QUANTITY)
      card[Label::QUANTITY].to_i.times { out_deck.push(trimmed_card.clone) }
    end
    out_deck
  end

  def collapse_complete(deck_object)
     out_deck = []
     temp_deck = deck_object.clone
     temp_deck.sort_by { |card| card[Label::DISPLAY_TOKEN] }
     hold_card = temp_deck[0]
     card_count = 1
     (1..temp_deck.length).each do |i|
        if(hold_card != temp_deck[i])
          hold_card[Label::QUANTITY] = card_count
          out_deck.push hold_card
          hold_card = temp_deck[i]
          card_count = 1
        else
          card_count += 1
        end
     end
     out_deck
  end

  private



end
