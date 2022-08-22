# test/system/games_test.rb
require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  test "Going to /new gives us a new random grid to play with" do
    visit new_url
    assert test: "New game"
    assert_selector ".item", count: 10
    test_word = "dfhjksfh"
    fill_in "input_word", with: test_word
    click_on "word-submit"
    assert_text "Sorry but #{test_word.upcase} does not seem to be a valid English word..."
  end
end
