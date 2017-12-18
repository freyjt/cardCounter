require 'rspec'
require 'spec_helper'
require_relative '../env.rb'

describe View do

  menuHash = [{ "displayToken" => "1",
                "displayOption" => "200"},
              { "displayToken" => "2",
                "displayOption" => "400"}]

  view_messages_path = "./resources/view/messages.json"
  before(:all) do
    @view_messages = JSON.parse(File.read(view_messages_path))
  end

  before(:each) do
    @view = View.new(view_messages_path)
  end

  after(:each) do
    @view = nil
  end

  it "#menu provides a user input if it is in the token list provided to the menu" do
    displayExpectationsMenu()
    expect(@view).to receive(:gets) { "1\n" }
    tokenBack = @view.menu(menuHash)
    expect(tokenBack).to eq("1")
  end

  it "#menu provides a failure statement if it can't get input 3 times" do
    displayExpectationsMenu()
    displayExpectationsMenu()
    displayExpectationsMenu()
    expect(@view).to receive(:gets) { "3\n" }.exactly(3).times 
    expect(@view).to receive(:puts).with(@view_messages["INCORRECT_INPUT"]).exactly(3).times
    expect(@view).to receive(:puts).with(@view_messages["GIVING_UP"])
    failure_output = @view.menu(menuHash)
    expect(failure_output).to eq("")
  end

  # @NOTE tight coupling with 'menuHash'
  def displayExpectationsMenu
    expect(@view).to receive(:puts).with(@view_messages["MENU_SEPARATOR"])
    expect(@view).to receive(:puts).with("1 - 200")
    expect(@view).to receive(:puts).with("2 - 400")
    expect(@view).to receive(:puts).with(@view_messages["MENU_SEPARATOR"])
    expect(@view).to receive(:puts).with("#{@view_messages["ENTER_DATA"]} menu option")
  end
end
