class Card
  attr_accessor :suit, :value
  def initialize(s, v)
    @suit = s
    @value = v
  end

  def pretty_output
    "#{@value} #{@suit}"
  end

  def to_s
    pretty_output
  end
end

class Deck
  def initialize
    @deck = []
    ['of Hearts', 'of Spades', 'of Diamonds', 'of Clubs'].each do |suit|
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
  def add_card(card)
    @hand << card
  end

  def display_hand
    puts "This is #{name}'s hand: "
    hand.each do|card|
      puts "#{card}"
    end
  end

  def sum_of_cards
    arr = @hand.map{|card| card.value}

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

  def busted 
    sum_of_cards > Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  attr_accessor :name, :hand
  include Hand

  def initialize(n)
    @name = n
    @hand = []
  end

  def set_name
    puts "---------- Welcome to Blackjack! -----------"
    puts "What is your name?"
    @name = gets.chomp
    puts "Welcome #{@name}!"
    sleep 0.5
    puts " "
  end
end

class Dealer
  include Hand
  attr_accessor :name, :hand

  def initialize
    @name = 'Dealer'
    @hand = []
  end 

  def show_flop
    puts "This is dealer's hand: "
    puts "First card is hidden."
    puts "Second card is #{hand[1]}"
  end
end

class Blackjack 
  attr_accessor :deck, :player, :dealer
  BLACKJACK_AMOUNT = 21
  DEALER_MIN = 17

  def initialize 
    @deck = Deck.new
    @player = Player.new('')
    @dealer = Dealer.new
    @current_player = @human
  end

  def deal_initial_cards
    player.add_card(deck.deal)
    dealer.add_card(deck.deal)
    player.add_card(deck.deal)
    dealer.add_card(deck.deal)
    puts "Dealing cards...."
    puts " "
    sleep 0.5
  end

  def show_initial_cards
    player.display_hand
    puts "This is #{player.name}'s total: #{player.sum_of_cards}"
    puts " "
    dealer.show_flop
  end

  def blackjack_or_bust(player_or_dealer)
    if player_or_dealer.sum_of_cards == BLACKJACK_AMOUNT
      
      if player_or_dealer.is_a?(Dealer)
        puts " "
        puts "Dealer has blackjack, #{player.name} has #{player.sum_of_cards}"
        puts "Sorry, dealer won."
      else 
        puts " "
        puts "Dealer has #{dealer.sum_of_cards}, #{player.name} has blackjack."
        puts "Congratulations, #{player.name} wins!"
      end

      play_again
    
    elsif player_or_dealer.sum_of_cards > BLACKJACK_AMOUNT
      
      if player_or_dealer.is_a?(Dealer)
        puts " "
        puts "Dealer has busted. #{player.name} wins!"
      else puts "Sorry #{player.name}, you've busted."
      end

      play_again
    end
  end

  def player_turn
    blackjack_or_bust(player)

    while !player.busted 
      puts " "
      puts "Would you like to hit or stay (h/s)?"
      player_move = gets.chomp.downcase

      if player_move == 'h'
        player.add_card(deck.deal)
        puts " "
        puts "#{player.name} took a hit"
        puts " "
        player.display_hand
        puts "This is #{player.name}'s total: #{player.sum_of_cards}"
        puts " "
        blackjack_or_bust(player)
      elsif player_move == 's'
        puts "#{player.name} chose to stay at #{player.sum_of_cards}"
        puts " "
        break
      else !['h', 's'].include?(player_move)
        puts "Error: Please choose 'h' or 's'"
        next
      end
    end
  end

  def dealer_turn
    blackjack_or_bust(dealer)
    while dealer.sum_of_cards < DEALER_MIN
      begin
        puts " "
        puts "Dealer hits..."
        sleep 0.5
        new_card = deck.deal
        puts "Dealer's card is: #{new_card}"
        dealer.add_card(new_card)
        puts " "
        dealer.display_hand
        puts "Dealer's total is: #{dealer.sum_of_cards}"
        puts " "
        blackjack_or_bust(dealer)
      end
    end
    puts " "
    dealer.display_hand
    puts " "
    puts "Dealer stays at #{dealer.sum_of_cards}"
  end

  def compare_hands
    if dealer.sum_of_cards > player.sum_of_cards
      puts "Dealer has #{dealer.sum_of_cards}, #{player.name} has #{player.sum_of_cards}"
      puts "Sorry, dealer won."
    elsif dealer.sum_of_cards < player.sum_of_cards
      puts "Dealer has #{dealer.sum_of_cards}, #{player.name} has #{player.sum_of_cards}"
      puts "Congratulations! #{player.name} has won!"
    else 
      puts "Dealer has #{dealer.sum_of_cards}, #{player.name} has #{player.sum_of_cards}"
      puts "You've tied!"
    end
    play_again
  end

  def play_again
    puts "Would you like to play again? (y/n)"
    continue = gets.chomp.downcase
    if continue == 'y'
      puts " "
      puts "Starting new game..."
      @deck = Deck.new
      @player = Player.new('')
      @dealer = Dealer.new
      start 
    else 
      puts "Goodbye!"
      exit
    end
  end

  def start
    deck.shuffle
    player.set_name
    deal_initial_cards
    show_initial_cards
    player_turn
    dealer_turn
    compare_hands
  end
end

game = Blackjack.new.start
