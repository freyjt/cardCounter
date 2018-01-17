require 'rspec'
require 'spec_helper'

require_relative '../env.rb'

describe ProbDecorator do

  JSON_DECK = JsonCollapser.new.decollapse(File.read PATH_TO_DEFAULT)

  def find_card_by_token(deck, token)
    out_card = nil
    deck.each do |card|
      out_card = card if(card[Label::DISPLAY_TOKEN] == token)
    end
    out_card
  end

  def count_deck(deck)
    count = 0
    deck.each { |card| count += card[Label::QUANTITY] }
    return count
  end

  def collapse()
    JsonCollapser.new.collapse_maintaining_groups @deck.full_deck_spy
  end

  def label_at_least(draws, at_least)
    "" + Label::DRAW_PROB_PREFIX + draws.to_s + Label::DRAW_AT_LEAST_MIDFIX + at_least.to_s
  end

  before(:each) do
    @deck = DeckBuilder.new JsonCollapser.new.decollapse(File.read PATH_TO_DEFAULT)
  end

  after(:each) do
    @deck = nil
  end

  it "#decorate 1 adds 1 when only one card is available on top-deck" do
    token_to_discard = "NY"
    @deck.move_to_discard(token_to_discard)
    @deck.add_discard_to_deck
    collapsed = JsonCollapser.new.collapse_maintaining_groups @deck.full_deck_spy
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate 1
    decorated = decorator.full_deck
    expected_guaranteed_card = find_card_by_token(decorated[1], token_to_discard)
    expect(expected_guaranteed_card[Label::DRAW_PROB_PREFIX + "1"]).to eq(1)
  end

  it "#decorate 1 does not decorate the bottom deck when 1 is available on top-deck" do
    token_to_discard = "NY"
    @deck.move_to_discard(token_to_discard)
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate 1
    decorated = decorator.full_deck
    expected_not_decorated = find_card_by_token(decorated[0], token_to_discard) # token used by convinience, any should work
    expect(expected_not_decorated[Label::DRAW_PROB_PREFIX + "1"]).to be(nil)
  end

  it "#decorate 1 adds .5 when there are two different cards on the top deck" do
    tokens_to_discard = ["NY", "SP"]
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate 1
    decorated = decorator.full_deck
    tokens_to_discard.each do |token|
      expected_fifty_fifty_card = find_card_by_token(decorated[1], token)
      expect(expected_fifty_fifty_card[Label::DRAW_PROB_PREFIX + "1"]).to eq(0.5)
    end
  end

  it "#decorate 2 adds 1 to both cards when two are on top deck" do
    tokens_to_discard = ["NY", "SP"]
    decorating_tag = 2
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    tokens_to_discard.each do |token|
      expected_guarantee_card = find_card_by_token(decorated[1], token)
      expect(expected_guarantee_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(1)
    end
  end

  it "#decorate 1 adds 0.3333 to cards when three are available" do
    expected_probability = 0.3333
    tokens_to_discard = ["NY", "SP", "WA"]
    decorating_tag = 1
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    tokens_to_discard.each do |token|
      expected_guarantee_card = find_card_by_token(decorated[1], token)
      expect(expected_guarantee_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(expected_probability)
    end
  end

  it "#decorate 2 adds 0.6667 when there are 3 cards available" do
    expected_probability = 0.6667
    tokens_to_discard = ["NY", "SP", "WA"]
    decorating_tag = 2
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    tokens_to_discard.each do |token|
      expected_guarantee_card = find_card_by_token(decorated[1], token)
      expect(expected_guarantee_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(expected_probability)
    end
  end

  it "#decorate 3 adds 1 when there are 3 cards available" do
    expected_probability = 1.0
    tokens_to_discard = ["NY", "SP", "WA"]
    decorating_tag = 3
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    tokens_to_discard.each do |token|
      expected_guarantee_card = find_card_by_token(decorated[1], token)
      expect(expected_guarantee_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(expected_probability)
    end
  end

  it "#decorate 4 sets the probability on the bottom deck when 3 cards on on top" do
    card_to_observe = "NY"
    prob_of_drawing_at_least_one_of_two_left = 0.0833
    tokens_to_discard = ["NY", "SP", "WA"]
    decorating_tag = 4
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(prob_of_drawing_at_least_one_of_two_left)
  end

  it "#decorate 5 sets the probability on the bottom deck when 3 cards on top" do
    card_to_observe = "NY"
    prob_of_drawing_at_least_one_of_two_left = 0.1630
    tokens_to_discard = ["NY", "SP", "WA"]
    decorating_tag = 5
    tokens_to_discard.each { |token| @deck.move_to_discard token }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new(collapsed)
    decorator.decorate decorating_tag
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[Label::DRAW_PROB_PREFIX + "#{decorating_tag}"]).to eq(prob_of_drawing_at_least_one_of_two_left)
  end

  it "#decorate_at_least(draws=1, at_least=2) sets the probability of at_least_2 to 0 if only one is available" do
    card_to_observe = "NY"
    draws = 1
    at_least = 2
    @deck.move_to_discard card_to_observe
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new collapsed
    decorator.decorate_at_least(draws=draws, at_least=at_least)
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[label_at_least(draws, at_least)]).to eq(0.0)
  end

  it "#decorate_at_least(draws=1, at_least=2 always adds 0.0" do
    card_to_observe = "NY"
    draws = 1
    at_least = 2
    collapsed = collapse
    decorator = ProbDecorator.new collapsed
    decorator.decorate_at_least(draws=draws, at_least=at_least)
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[label_at_least(draws, at_least)]).to eq(0.0)
  end

  it "#decorate_at_least(draws=2, at_least=3 always adds 0.0" do
    card_to_observe = "NY"
    draws = 2
    at_least = 3
    collapsed = collapse
    decorator = ProbDecorator.new collapsed
    decorator.decorate_at_least(draws=draws, at_least=at_least)
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[label_at_least(draws, at_least)]).to eq(0.0)
  end

  it "#decorate_at_least(draws=2, at_least=2) applies 1.0 when two are both the same" do
    card_to_observe = "NY"
    draws = 2
    at_least = 2
    draws.times { @deck.move_to_discard card_to_observe }
    @deck.add_discard_to_deck
    collapsed = collapse
    decorator = ProbDecorator.new collapsed
    decorator.decorate_at_least(draws=draws, at_least=at_least)
    decorated = decorator.full_deck
    expected_card = find_card_by_token(decorated[0], card_to_observe)
    expect(expected_card[label_at_least(draws, at_least)]).to eq(1.0)
  end

end

