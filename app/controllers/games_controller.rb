require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    clear_session if params[:reset] == 'true'
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @letters = params['grid_letters'].split('')
    @input = params['input_word'].gsub(/\s+/, '').upcase
    @input_array = @input.split('')
    calculate_score
    if letters_present? && english_word?
      @return_message = return_statements('congratulations')
    elsif letters_present? && !english_word?
      @return_message = return_statements('not english')
    elsif !letters_present? && english_word?
      @return_message = return_statements('not enough letters')
    end
  end

  private

  # Clear the current session to reset grand total
  def clear_session
    session[:grand_total] = 0
  end

  # Handle score calculation
  def calculate_score
    @score = @input_array.length
    session[:grand_total] ? session[:grand_total] += @score : session[:grand_total] = @score
    @grand_total = session[:grand_total]
  end

  # Collection of all the statements returned to user
  def return_statements(required_statement)
    case required_statement
    when 'not enough letters'
      "Sorry but #{@input.upcase} cannot be built out of #{@letters.join.upcase}"
    when 'not english'
      "Sorry but #{@input.upcase} does not seem to be a valid English word..."
    when 'congratulations'
      "Congratulations! #{@input.upcase} is a valid English word!"
    end
  end

  # Are letters present and is the word english?
  def letters_present?
    grid_count = {}
    input_count = {}
    @enough_letters = true
    @letters.each { |letter| grid_count.key?(letter) ? grid_count[letter] += 1 : grid_count[letter] = 1 }
    @input_array.each { |letter| input_count.key?(letter) ? input_count[letter] += 1 : input_count[letter] = 1 }
    input_count.each do |key, value|
      @enough_letters = false if grid_count[key].nil? || value > grid_count[key]
    end
  end

  def english_word?
    url = "https://wagon-dictionary.herokuapp.com/#{@input.downcase}"
    attempt_serialized = URI.open(url).read
    JSON.parse(attempt_serialized)['found']
  end
end
