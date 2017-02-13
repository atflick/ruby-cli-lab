require "pry"

$line_break = "#" * 55
$tf = [true, false]
$abc = ["a","b","c","d","e","f","g","h","i","j"]

class GameBoard
  attr_accessor :grid, :lives, :hits, :targets
  def initialize
    @grid = []
    @lives = 30
    @hits = 0
    @targets = 18
    self.build_grid
  end
  # builds hidden 10x10 grid, with "cells" containing hidden info that is used to be checked/searched from other methods
  def build_grid
    x = 0
    10.times do
      row = []
      y = 0
      10.times do
        row.push({display: "~~", ship: false, coord: [x, y]})
        y += 1
      end
      self.grid << row
      x += 1
    end
    p self.grid
  end
  # clears and prints battleship header in cl
  def print_head
    system "clear"
    puts $line_break
    puts "##   ___  ___ ______________   __________ _________  ##"
    puts "##  / _ )/ _ /_  __/_  __/ /  / __/ __/ // /  _/ _ \\ ##"
    puts "## / _  / __ |/ /   / / / /__/ _/_\\ \\/ _  // // ___/ ##"
    puts "##/____/_/ |_/_/   /_/ /____/___/___/_//_/___/_/     ##"
    puts "##                                                   ##"
  end
  # prints viewable grid from "hidden" grid (array)
  def print_grid
    self.print_head
    puts $line_break
    i = 0
    grid.each do |row|
      printable_row = []
      row.each do |cell|
        printable_row << cell[:display]
      end
      row_string = printable_row.join(" | ")
      puts "## #{$abc[i].upcase} #{row_string} ##"
      # puts "##   #{row_string} ##"
      puts "##" + "------" + "+----" * 9  + "##"
      i += 1
    end
    bottom_row = []
    l = 0
    10.times do
      bottom_row << " #{l}  "
      l += 1
    end
    print_row = bottom_row.join("|")
    puts "##  #{print_row}##"
    puts $line_break
  end
  # adds ships randomly to board, can take them based on size. places based on position that is randomly created when the ship is created
  def place_ship(boat)
    x = 10 - boat.size
    # vertical ship
    if boat.position
      start_row = (0..x).to_a.sample
      start_col = (0...10).to_a.sample
      row_check = start_row
      # checking if boat already exists in location, if so run place boat again with same boat
      boat.size.times do
        if $new_game.grid[row_check][start_col][:ship] == true
          $new_game.place_ship(boat)
          break
        end
        row_check += 1
      end
      boat.size.times do
        $new_game.grid[start_row][start_col][:ship] = true
        start_row += 1
      end
      # horizontal ship
    else
      start_row = (0...10).to_a.sample
      start_col = (0..x).to_a.sample
      col_check = start_col
      # checking if boat already exists in location, if so run place boat again with same boat
      boat.size.times do
        if $new_game.grid[start_row][col_check][:ship] == true
          $new_game.place_ship(boat)
          break
        end
        col_check += 1
      end
      boat.size.times do
        $new_game.grid[start_row][start_col][:ship] = true
        start_col += 1
      end
    end
  end

end
# ship/boat class that creates ships. passes in aan argument for size
class Boat
  attr_accessor :size, :position
  def initialize(size)
    @size = size
    # Determines vertical (true) or horizontal (false)
    @position = $tf.sample
  end
end

$boat_1 = Boat.new(5)
$boat_2 = Boat.new(4)
$boat_3 = Boat.new(4)
$boat_4 = Boat.new(3)
$boat_5 = Boat.new(2)

$boats = [$boat_1, $boat_2, $boat_3, $boat_4, $boat_5]

class MenuPrompts
  attr_accessor :scores, :tries, :input
  def initialize
    @score = 0
    @tries = 10
    @input = ""
  end

  def welcome
    system "clear"
    puts $line_break
    puts "##" + " "*51 + "##"
    puts "##" +" "*14+"Welcome to Battleship!!"+" "*14+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
    puts "##" + " "*51 + "##"
    puts "##" + " "*16+"1. Play new game   "+" "*16+"##"
    puts "##" + " "*16+"2. Quit            "+" "*16+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
    # self.input = ""
    while self.input != "2"
      self.input = gets.chomp.downcase
      if self.input == "1"
        $boats.each {|b| $new_game.place_ship(b)}
        $new_game.print_grid
        $prompt.collect_coords
      elsif self.input == "3"
        self.hit
      else
        puts "Invalid response"
      end
    end
  end
  # prints info/scoring box
  def info
    puts "##" + " "*51 + "##"
    puts "##" + " "*5+"Lives:  #{self.two_dig($new_game.lives)}   Hits:  #{self.two_dig($new_game.hits)}   Targets:  #{self.two_dig($new_game.targets)}    "+" "*5+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
  end

  # asks user for coordinates, prompts for row and col coords. repeats if it doesn't get correct response
  def collect_coords
    if $new_game.lives == 0
      self.game_over
    elsif $new_game.targets == 0
      self.win
    else
      $new_game.print_grid
      self.info
      row = "z"
      while $abc.index(row) == nil
        puts "Enter row coordinate (A - J):"
        row = gets.chomp.downcase.to_s
        row_num = $abc.index(row)
      end
      col = ""
      while ("0".."9").to_a.index(col) == nil
        puts "Enter column coordinate (0 - 9):"
        col = gets.chomp
      end
      self.check_coords([row_num,col.to_i])
    end
  end
# Takes coordinates input from user, searches grid for ship.  if true then hit or false miss
  def check_coords(coord)
    target = $new_game.grid[coord[0]][coord[1]]
    if target[:ship] == true
      $new_game.hits += 1
      $new_game.targets -= 1
      target[:display] = "XX"
      self.hit
    else
    # Miss
      target[:display] = "OO"
      $new_game.lives -= 1
      self.miss
    end
    $prompt.collect_coords
  end

  def new_game
    puts $line_break
    puts "##" + " "*51 + "##"
    puts "##" + " "*16+"1. Play new game   "+" "*16+"##"
    puts "##" + " "*16+"2. Quit            "+" "*16+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
    # self.input = ""
    while self.input != "2"
      self.input = gets.chomp.downcase
      if self.input == "1"
        $new_game = GameBoard.new
        $boats.each {|b| $new_game.place_ship(b)}
        $new_game.print_grid
        $prompt.collect_coords
      elsif self.input == "3"
        self.hit
      else
        puts "Invalid response"
      end
    end
  end

  def two_dig(num)
    format('%02d', num)
  end

  def game_over
    system "clear"
    puts $line_break
    puts "##          ______   ___       __  ___   ______      ##"
    puts "##         / ____/  /   |     /  |/  /  / ____/      ##"
    puts "##        / / __   / /| |    / /|_/ /  / __/         ##"
    puts "##       / /_/ /  / ___ |   / /  / /  / /___         ##"
    puts "##       \\____/  /_/  |_|  /_/  /_/  /_____/         ##"
    puts "##                                                   ##"
    puts "##          ____     _    __   ______   ____         ##"
    puts "##         / __ \\   | |  / /  / ____/  / __ \\        ##"
    puts "##        / / / /   | | / /  / __/    / /_/ /        ##"
    puts "##       / /_/ /    | |/ /  / /___   / _, _/         ##"
    puts "##       \\____/     |___/  /_____/  /_/ |_|          ##"
    puts "##                                                   ##"
    puts $line_break
    self.new_game
  end

  def win
    system "clear"
    puts $line_break
    puts "##                __  __   ____     __  __           ##"
    puts "##                \\ \\/ /  / __ \\   / / / /           ##"
    puts "##                 \\  /  / / / /  / / / /            ##"
    puts "##                 / /  / /_/ /  / /_/ /             ##"
    puts "##                /_/   \\____/   \\____/              ##"
    puts "##                                                   ##"
    sleep 1
    puts "##           _____    __  __   _   __   __ __        ##"
    puts "##          / ___/   / / / /  / | / /  / //_/        ##"
    puts "##          \\__ \\   / / / /  /  |/ /  / ,<           ##"
    puts "##         ___/ /  / /_/ /  / /|  /  / /| |          ##"
    puts "##        /____/   \\____/  /_/ |_/  /_/ |_|          ##"
    puts "##                                                   ##"
    sleep 1
    puts "##                  __  ___   __  __                 ##"
    puts "##                 /  |/  /   \\ \\/ /                 ##"
    puts "##                / /|_/ /     \\  /                  ##"
    puts "##               / /  / /      / /                   ##"
    puts "##              /_/  /_/      /_/                    ##"
    puts "##                                                   ##"
    sleep 1
    $new_game.print_head
    self.new_game
  end

  def hit
    $new_game.print_head
    puts ("#" * 55 +"\n") * 23
    self.info
    sleep 1
    $new_game.print_head
    puts ("#" * 55 +"\n") * 8
    puts "##              _   _   ___   _____   _              ##"
    puts "##             | | | | |_ _| |_   _| | |             ##"
    puts "##             | |_| |  | |    | |   | |             ##"
    puts "##             |  _  |  | |    | |   |_|             ##"
    puts "##             |_| |_| |___|   |_|   (_)             ##"
    puts "##"+ " "* 51 +"##\n"
    puts ("#" * 55 +"\n") * 9
    self.info
    sleep 1
    $new_game.print_grid
  end

  def miss
    $new_game.print_head
    puts ("#" * 55 +"\n") * 23
    self.info
    sleep 1
    $new_game.print_head
    puts ("#" * 55 +"\n") * 8
    puts "##         __  __   ___   ____    ____    _          ##"
    puts "##        |  \\/  | |_ _| / ___|  / ___|  | |         ##"
    puts "##        | |\\/| |  | |  \\___ \\  \\___ \\  | |         ##"
    puts "##        | |  | |  | |   ___) |  ___) | |_|         ##"
    puts "##        |_|  |_| |___| |____/  |____/  (_)         ##"
    puts "##"+ " "* 51 +"##\n"
    puts ("#" * 55 +"\n") * 9
    self.info
    sleep 1
    $new_game.print_grid
  end
end

$new_game = GameBoard.new
$prompt = MenuPrompts.new

$prompt.welcome

binding.pry
