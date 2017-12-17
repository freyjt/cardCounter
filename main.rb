require_relative './env.rb'

CITY_PATH = "./resources/cities.json"

# @TODO move me to a view object
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
