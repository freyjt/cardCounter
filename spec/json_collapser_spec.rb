require 'rspec'
require 'spec_helper'

require_relative '../env.rb'

describe JsonCollapser do

  PATH_TO_DEFAULT = "./resources/default_cities.json"
  DEFAULT_DECK_LENGTH = 27
  DEFAULT_DECK_UNIQUE_LENGTH = 9
  DEFAULT_DECK_ALL_ITEMS_COUNT = 3

  before(:each) do
    @jsonCollapser = JsonCollapser.new()
  end

  # @TODO method signature? should be something in the dao world.
  it "decollapses a string of cards with counts to be a list of individuals" do
    json_string = File.read(PATH_TO_DEFAULT)
    my_deck = @jsonCollapser.decollapse(json_string)
    expect(my_deck.length).to eq(DEFAULT_DECK_LENGTH)
  end

  it "#collapse a standard deck object into a card list with counts" do
    deck_obj = @jsonCollapser.decollapse File.read(PATH_TO_DEFAULT)
    collapsed_deck = @jsonCollapser.collapse_complete deck_obj
    expect(collapsed_deck.length).to eq(DEFAULT_DECK_UNIQUE_LENGTH)
    expect(collapsed_deck).to be_an_instance_of(Array)
  end

  it "#collapse_complete provides a default deck with counts all equal" do
    deck_obj = @jsonCollapser.decollapse File.read(PATH_TO_DEFAULT)
    collapsed_deck = @jsonCollapser.collapse_complete deck_obj
    collapsed_deck.each do |card|
      expect(card[Label::QUANTITY]).to eq(DEFAULT_DECK_ALL_ITEMS_COUNT)
    end
  end


end
