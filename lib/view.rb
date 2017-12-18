

class View
  
  def initialize(message_path)
    @display_messages = JSON.parse(File.read(message_path))
  end

  # return menu choice
  # call with menu items to get menu
  # call with cities in deck for 'epidemic'
  # call with cities on top for normal draw
  def menu(menu_hash, choice_descriptor = "menu option")
    fail_counter = 0
    menu_symbols = menu_hash.map { |item| item["displayToken"] } # @TODO Law of demeter violation. Hand it what it expects, call #keys
    menu_k_v = menu_hash.map { |item| [ "#{item["displayToken"]}", "#{item["displayOption"]}" ] } # @TODO Law of demeter violation. Hand it what it expects
    while(true)
      display_hash(menu_k_v) 
      token_input = line_input("#{@display_messages["ENTER_DATA"]} #{choice_descriptor}")
      if(menu_symbols.include? token_input)
        return token_input
      else
        puts @display_messages["INCORRECT_INPUT"]
        fail_counter += 1
        if(fail_counter >= 3)
          puts @display_messages["GIVING_UP"]
          return ""
        end
      end
    end
  end

  # dataIn should be an array of k->v pairs
  def display_hash(dataIn)
    puts @display_messages["MENU_SEPARATOR"]
    dataIn.each do |key, value|
      puts "#{key} - #{value}"
    end
    puts @display_messages["MENU_SEPARATOR"]
  end

  private

  def line_input(request)
    puts request
    return gets.chomp
  end
end
