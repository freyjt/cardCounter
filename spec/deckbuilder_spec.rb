require 'rspec'
require 'spec_helper'
require_relative '../env.rb'


describe DeckBuilder do

  PATH_TO_DEFAULT = "./resources/default_cities.json"
  NY_OBJECT = { "displayOption" => "New York", "displayToken" => "NY" }

  before(:each) do
    @deck_builder = DeckBuilder.new(PATH_TO_DEFAULT)
  end

  it "#read_from_file returns array of 1 element for each card in deck" do
    default_deck = @deck_builder.load_from_file(PATH_TO_DEFAULT)
    expect(default_deck.length).to eq(27) # starting size of pandemic legacy season 2
  end

  it "#read_from_file default includes object NY" do
    default_deck = @deck_builder.load_from_file(PATH_TO_DEFAULT)
    expect(default_deck).to include(NY_OBJECT) # starting size of pandemic legacy season 2
    
  end

end

