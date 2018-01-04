require 'rspec'
require 'spec_helper'
require_relative '../env.rb'

describe DeckBuilder do

  DEFAULT_DECK_SIZE = 27
  NY_OBJECT = { Label::DISPLAY_OPTION => "New York", Label::DISPLAY_TOKEN => "NY" }

  def remove_some(token, count)
    count.times { @deck_builder.move_to_discard(token) }
  end

  def count_token(token)
    @deck_builder.top_deck_spy.select { |entity| entity["displayToken"] == token }.length
  end

  def remove_some_random(count)
    count.times do 
      discard_token = @deck_builder.top_deck_spy.sample["displayToken"]
      @deck_builder.move_to_discard(discard_token)
    end
  end

  before(:each) do
    json_string = File.read(PATH_TO_DEFAULT)
    deck_list = JsonCollapser.new.decollapse(json_string)
    @deck_builder = DeckBuilder.new(deck_list)
  end

  it "#read_from_file returns array of 1 element for each card in deck" do
    expect(@deck_builder.length).to eq(DEFAULT_DECK_SIZE) # starting size of pandemic legacy season 2
  end

  it "#read_from_file default includes object NY" do
    expect(@deck_builder.top_deck_spy).to include(NY_OBJECT)
    expect(@deck_builder.bottom_deck_spy).to include(NY_OBJECT)
    expect(@deck_builder.full_deck_spy[0]).to include(NY_OBJECT)
  end

  it "#move_to_discard increases discard by 1" do
     @deck_builder.move_to_discard("NY")
     expect(@deck_builder.bottom_deck_spy.length).to be(DEFAULT_DECK_SIZE - 1)
     expect(@deck_builder.discard_spy.length).to be( 1 )
  end

  it "#move_to_discard breaks when the token is not known" do
     expect { @deck_builder.move_to_discard("Ottawa") }.to raise_error(CardCounterError::TokenNotFound)
  end

  it "#move_from_bottom_to_discard increases discard by 1" do
    @deck_builder.move_from_bottom_to_discard("NY")
    expect(@deck_builder.bottom_deck_spy.length).to be(DEFAULT_DECK_SIZE - 1)
    expect(@deck_builder.discard_spy.length).to be(1)
  end

  it "#move_from_bottom_to_discard reduces size of bottom when there is a top" do
    remove_some_random(10)
    before_size = @deck_builder.bottom_deck_spy.length
    @deck_builder.add_discard_to_deck
    remove_some_random(5) # mimics actual expected behavior
    token_still_in_bottom = @deck_builder.bottom_deck_spy.sample["displayToken"]
    @deck_builder.move_from_bottom_to_discard(token_still_in_bottom)
    expect(@deck_builder.discard_spy.length).to eq(6) # from the five we took out + 1
    expect(@deck_builder.bottom_deck_spy.length).to eq(before_size - 1)
  end

  it "#move_from_bottom_to_discard throws error when token is unavailable" do
    expect { @deck_builder.move_from_bottom_to_discard("Ottawa") }.to raise_error(CardCounterError::TokenNotFound)
  end

  it "#top_deck_spy cannot mutate the original deck" do
    expected_deck = @deck_builder.top_deck_spy
    expected_deck.push({"some" => "objext"})
    after_deck_length = @deck_builder.top_deck_spy.length
    expect(after_deck_length).not_to eq(expected_deck.length)
    expect(after_deck_length + 1).to eq(expected_deck.length)
  end

  it "#add_discard_to_deck increases the length of the deck by one when there is a discard pile" do
    starting_deck_length = @deck_builder.deck_stack_depth_spy
    remove_some("NY", 2)
    @deck_builder.add_discard_to_deck
    ending_deck_length = @deck_builder.deck_stack_depth_spy
    expect(starting_deck_length).to eq((ending_deck_length - 1))
  end

  it "#add_discard_to_deck does not increase the length of the deck if the discard pile is empty" do
    starting_deck_length = @deck_builder.deck_stack_depth_spy
    @deck_builder.add_discard_to_deck
    ending_deck_length = @deck_builder.deck_stack_depth_spy
    expect(starting_deck_length).to eq(ending_deck_length)
  end

  it "#possible_draws_grouped returns an array" do
    possible_draws = @deck_builder.possible_draws_grouped(1)
    expect(possible_draws).to be_an_instance_of(Array)
  end

  it "#possible_draws_grouped(1) returns 1x1 array after epidemic of only one entity" do
    remove_some("NY", 1)
    @deck_builder.add_discard_to_deck
    possible_draws = @deck_builder.possible_draws_grouped(1)
    expect(possible_draws.length).to eq(1)
    expect(possible_draws[0].length).to eq(1)
  end

  it "#possible_draws_grouped(2) returns 2x array after epidemic of only one entity" do
    expected_length_of_possible = 2
    expected_length_of_top = 1
    expected_length_of_bottom = @deck_builder.bottom_deck_spy.length - expected_length_of_top
    remove_some("NY", 1)
    @deck_builder.add_discard_to_deck
    possible_draws = @deck_builder.possible_draws_grouped(2)
    expect(possible_draws.length).to eq(2)
    expect(@deck_builder.top_deck_spy.length).to eq(expected_length_of_top)
    expect(@deck_builder.bottom_deck_spy.length).to eq(expected_length_of_bottom)
  end

  it "#possible_draws_grouped(5) returns an array of length 3 after 3 discards, epidemic, 1 discard" do
    expected_length_of_possible = 3
    expected_length_of_top = 1
    expected_length_of_middle = 2
    expected_length_of_bottom = @deck_builder.bottom_deck_spy.length - expected_length_of_top - expected_length_of_middle
    remove_some_random(3)
    @deck_builder.add_discard_to_deck
    remove_some_random(1)
  end

  it "#possible_draws_grouped(-2) throws IllegalArgument Error" do
    expect { @deck_builder.possible_draws_grouped(-2) }.to raise_error(CardCounterError::IllegalArgument)
  end

  it "#possible_draws_grouped throws IllegalArgument when number is greater than the deck size" do
    too_big_deck_size = @deck_builder.bottom_deck_spy.length + 1
    expect { @deck_builder.possible_draws_grouped(too_big_deck_size) }.to raise_error(CardCounterError::IllegalArgument)
  end

  it "#full_deck_spy gives a deep copy after an epidemic" do
    remove_some("NY", 3)
    @deck_builder.add_discard_to_deck
    after_clone = @deck_builder.full_deck_spy
    expect(after_clone[1][1]).to eq(NY_OBJECT)
  end
end
