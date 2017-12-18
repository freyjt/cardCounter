require_relative './env.rb'

CITY_PATH = "./resources/cities.json"
MENU_PATH = "./resources/main_menu.json"
VIEW_DISPLAY_PATH = "./resources/view/messages.json"

def main

  #  Possible draws is an array of objects
  #  It starts as a copy of the deck
  #  On epidemic the discard pile becomes an object pushed on top of array
  #  When one object empties, it pops off the array
  #  When in between objects, display both guarantees and possibilities
  def drawCard()
    # determine possible draws
    possible_draws = @deck_builder.possible_draws() 
    # display probabilities
    card_drawn = @view.menu(possible_draws)
    # remove from current possible
    # add to discard pile
    @deck_builder.remove_card card_drawn
  end


  def exitSafely()
    # @TODO save changes, make backup, etc
    exit
  end

  # Kinda expects the structs in main_menu
  def findCallToken(display_token, main_menu)
    main_menu.each do |menu_item|
      return menu_item["callToken"] if(menu_item["displayToken"] == display_token)
    end
    raise ArgumentError("Something didn't check right, sorry.")
  end

  @deckbuilder = DeckBuilder.new()
  @view = View.new VIEW_DISPLAY_PATH
  main_menu = JSON.parse(File.read(MENU_PATH))
  while(true)
    chosen_token = @view.menu(main_menu)
    next if chosen_token == "" # @TODO how is this not a null check?
    public_send(findCallToken(chosen_token, main_menu))
  end

end

main if __FILE__ == $0
