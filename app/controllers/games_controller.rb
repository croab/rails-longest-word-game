require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    @letters = []
    10.times do
      @letters << ('A'..'Z').to_a.sample
    end
  end

  def score
    @letters = params['grid_letters'].split('')
    @input = params['input_word'].gsub(/\s+/, '').upcase
    @input_array = @input.split('')
    not_enough_letters = "Sorry but #{@input.upcase} cannot be built out of #{@letters.join().upcase}"
    not_english = "Sorry but #{@input.upcase} does not seem to be a valid English word..."
    congratulations = "Congratulations! #{@input.upcase} is a valid English word!"
    @return_message = ''
    if letters_present? && english_word?
      @return_message = congratulations
    elsif letters_present? && !english_word?
      @return_message = not_english
    elsif !letters_present? && english_word?
      @return_message = not_enough_letters
    end
  end

  private

  def letters_present?
    grid_count = {}
    input_count = {}
    @enough_letters = true
    @letters.each do |grid_letter|
      grid_count.key?(grid_letter) ? grid_count[grid_letter] += 1 : grid_count[grid_letter] = 1
    end
    @input_array.each do |input_letter|
      input_count.key?(input_letter) ? input_count[input_letter] += 1 : input_count[input_letter] = 1
    end
    input_count.each do |key, value|
      if grid_count[key]
        @enough_letters = false if value > grid_count[key]
      else
        @enough_letters = false
      end
    end
  end

  def english_word?
    url = "https://wagon-dictionary.herokuapp.com/#{@input.downcase}"
    attempt_serialized = URI.open(url).read
    attempt_result = JSON.parse(attempt_serialized)
    return attempt_result["found"]
  end
end
