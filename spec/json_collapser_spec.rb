require 'rspec'
require 'spec_helper'

require_relative '../env.rb'

describe JsonCollapser do

  DEFAULT_DECK_LENGTH = 27
  DEFAULT_DECK_UNIQUE_LENGTH = 9
  DEFAULT_DECK_ALL_ITEMS_COUNT = 3

  def find_card_in(deck, token)
    deck.each do |card|
      return card if(card[Label::DISPLAY_TOKEN] == token)
    end
  end

  before(:each) do
    @jsonCollapser = JsonCollapser.new()
    @deck_array = @jsonCollapser.decollapse File.read(PATH_TO_DEFAULT)
  end

  # @TODO method signature? should be something in the dao world.
  it "decollapses a string of cards with counts to be a list of individuals" do
    expect(@deck_array.length).to eq(DEFAULT_DECK_LENGTH)
  end

  it "#collapse a standard deck object into a card list with counts" do
    collapsed_deck = @jsonCollapser.collapse_complete @deck_array
    expect(collapsed_deck.length).to eq(DEFAULT_DECK_UNIQUE_LENGTH)
    expect(collapsed_deck).to be_an_instance_of(Array)
  end

  it "#collapse_complete provides a default deck with counts all equal" do
    deck_obj = @jsonCollapser.decollapse File.read(PATH_TO_DEFAULT)
    collapsed_deck = @jsonCollapser.collapse_complete @deck_array
    collapsed_deck.each do |card|
      expect(card[Label::QUANTITY]).to eq(DEFAULT_DECK_ALL_ITEMS_COUNT)
    end
  end

  it "#collapse_maintaining_groups leaves the deck size as 1 when given a standard deck array" do
    deck_to_collapse = DeckBuilder.new(@deck_array).full_deck_spy
    collapsed_deck = @jsonCollapser.collapse_maintaining_groups deck_to_collapse
    expect(collapsed_deck.length).to eq(1)
  end

  it "#collapse_maintaining_groups leaves the deck size as 2 when a deck has has draws and restacks" do
    deck_to_build = DeckBuilder.new(@deck_array)
    deck_to_build.move_to_discard("NY")
    deck_to_build.move_to_discard("SP")
    deck_to_build.move_to_discard("SP")
    deck_to_build.add_discard_to_deck
    deck_to_collapse = deck_to_build.full_deck_spy
    collapsed_deck = @jsonCollapser.collapse_maintaining_groups deck_to_collapse
    expect(collapsed_deck.length).to eq(2)
  end

  it "#collapse_maintaining_groups has the correct number of SP when two are on top" do
    token_expected_twice = "SP"
    deck_to_build = DeckBuilder.new(@deck_array)
    deck_to_build.move_to_discard("NY")
    deck_to_build.move_to_discard(token_expected_twice)
    deck_to_build.move_to_discard(token_expected_twice)
    deck_to_build.add_discard_to_deck
    deck_to_collapse = deck_to_build.full_deck_spy
    collapsed_deck = @jsonCollapser.collapse_maintaining_groups deck_to_collapse
    card_expected_twice = find_card_in(collapsed_deck.last, token_expected_twice)
    expect(card_expected_twice[Label::QUANTITY]).to eq(2)
  end

end
