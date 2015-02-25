class Card
  attr_accessor :suit, :value
  def initialize(s, v)
    @suit = s
    @value = v
  end

  def pretty_output
    puts "The #{value} #{suit}"
  end

  def to_s
    pretty_output
  end
end

class Deck
  def initialize
    @deck = []
    [' of Hearts', ' of Spades', ' of Diamonds', ' of Clubs'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'].each do |value|
        @deck << Card.new(suit, value)
      end
    end
  end

  def shuffle
    @deck.shuffle! 
  end

  def deal
    @deck.pop
  end 
end

module Hand
  def hand(card)
    @hand << card
  end

  def display_hand
    @hand
  end

  def sum_of_cards
    arr = @hand.map{|x| x[0]}

    total = 0
    arr.each do |x|
      if x == 'Ace'
        total += 11
      elsif x.to_i == 0 
        total += 10
      else
        total += x.to_i
      end
    end

    if total > 21
      arr.count('Ace').times do 
        total -= 10
      end
    end
    total 
  end 
end

class Player
  attr_accessor :name
  include Hand

  def initialize(n)
    @name = n
    @hand = []
  end

  def set_name
    puts "------------------- Welcome to Casino Ruby! This is the Blackjack table. -----------------------"
    puts "What is your name?"
    @name = gets.chomp
    puts "Welcome #{@name}"
  end
end

class Dealer
  include Hand

  def initialize(n)
    @name = n
    @hand = []
  end 
end

class Blackjack 
  def initialize 
    @deck = Deck.new
    @human = Player.new('')
    @computer = Dealer.new('Ruby')
    @current_player = @human
  end

  def deal_cards
    human.add_card(deck.deal)
    computer.add_card(deck.deal)
  end

  def player_turn
      begin
        puts "Would you like to hit or stay? (h/s)"
        action = gets.chomp.downcase 
      end until action == 'h' || action == 's'
      if action == 'h'
        @human.add_card(@deck.deal)
        puts "These are you cards: " 
        @human.display_hand
        puts "This is your total: #{@human.sum_of_cards}"
      end
    else @computer.add_card(@deck.deal)
      puts "These are dealer's cards: "
      @computer.display_hand
      puts "This is dealer's total: #{@computer.sum_of_cards}"
    end
  end

  def alternate_players
    if @current_player == @human
      @current_player = @computer
    else @current_player = @human
    end
  end

  def player_win_bust(total_cards)
    if total_cards == 21
      return "You win!"
    elsif total_cards > 21
      return "You have bust."
    end
    nil
  end

  def bust_or_compare_hands(player_total, dealer_total)
    if dealer_total >= 17 && 21 >= dealer_total && player_total > dealer_total
      return "You win! Your hand is: #{player_total}. Dealers hand is: #{dealer_total}."
    elsif dealer_total >= 17 && 21 >= dealer_total && player_total < dealer_total
      return "Dealer wins! Your hand is: #{player_total}. Dealers hand is: #{dealer_total}."
    elsif dealer_total > 21 
      return "Dealer bust. You win!"
    end 
    nil 
  end

  def play
    puts @deck
    @deck.shuffle
    @human.set_name 
    @human.add_card(@deck.deal)
    puts "This is your hand: "
    @human.display_hand
    @computer.add_card(@deck.deal)
    puts "This is dealer's hand: "
    @computer.display_hand
    loop do 
      choose_hit_or_stay
      if player_win_bust(@human.sum_of_cards)
        break 
      elsif @computer.sum_of_cards > 17 && @computer.sum_of_cards < 21
        puts "Dealer stays"
      else  
        alternate_players
      end
    end 
    bust_or_compare_hands(@human.sum_of_cards, @computer.sum_of_cards)
    



    #   begin
    #   puts "Would you like to hit or stay (h/s)?"
    #   player_move = gets.chomp.downcase 
    #   players_cards << deck.pop
    #   if player_move == 's' 
    #     break
    #   end
    #   puts "These are your cards: #{players_cards.flatten}"
    #   player_total = sum_of_cards(players_cards)
    #   puts "This is your total: #{player_total}"
    # end until player_move == 's' || player_win_bust(player_total) 

    # if player_win_bust(player_total)
    #   puts player_win_bust(player_total) 
    # end 
  end
end

game = Blackjack.new.play
