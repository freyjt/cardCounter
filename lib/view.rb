

class View
  # return menu choice
  def menu( )
     puts "--------------------------"
     puts " 1 - draw cards"
     puts " 2 - print probabilities"
     puts " 3 - epidemic"
     puts " 4 - add or adjust cities"
     puts ""
     return gets.chomp
  end


  def show_probabilities(probs)

  end


  def epidemic_input(cities)
    city_symbols = cities.map { |city| city.symbols } 
    fail_counter = 0
    while(true)
      show_cities_in_deck(cities)
      epidemic_city = get_input()
      # @TODO SHOULD THIS INPUT BE TOKENIZED OR NORMAL
      if(city_symbols.include?(epidemic_city) return epidemic_city
      else
        put "Invalid input "
        fail_counter += 1
        if(fail_counter >= 3)
          puts "returning none"
          return ""
        end
        puts "try again"
      end
    end
  end

  private

  def show_cities_in_deck(cities)


  end

  def get_input
end
