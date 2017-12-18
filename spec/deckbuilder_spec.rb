require 'rspec'
require 'spec_helper'
require_relative '../env.rb'


describe DeckBuilder do

  PATH_TO_DEFAULT = "./resources/default_cities.json"
  DEFAULT_DECK_SIZE = 27
  NY_OBJECT = { "displayOption" => "New York", "displayToken" => "NY" }

  before(:each) do
    @deck_builder = DeckBuilder.new(PATH_TO_DEFAULT)
  end

  it "#read_from_file returns array of 1 element for each card in deck" do
    default_deck = @deck_builder.load_from_file(PATH_TO_DEFAULT)
    expect(default_deck.length).to eq(DEFAULT_DECK_SIZE) # starting size of pandemic legacy season 2
  end

  it "#read_from_file default includes object NY" do
    default_deck = @deck_builder.load_from_file(PATH_TO_DEFAULT)
    expect(default_deck).to include(NY_OBJECT)
    
  end

  it "#move_to_discard increases discard by 1" do
     @deck_builder.move_to_discard("NY")
     expect(@deck_builder.bottom_deck_spy.length).to be(DEFAULT_DECK_SIZE - 1)
     expect(@deck_builder.discard_spy.length).to be( 1 )
  end

  it "#move_to_discard breaks when the token is not known" do
     @deck_builder.move_to_discard("Ottawa")
  end

end

