require "pry"

$line_break = "#" * 55
$tf = [true, false]
$abc = ["a","b","c","d","e","f","g","h","i","j"]

class GameBoard
  attr_accessor :grid
  def initialize
    @grid = []
    self.build_grid
  end
# builds hidden 10x10 grid, with "cells" containing hidden info that is used to be checked/searched from other methods
  def build_grid
    x = 0
    10.times do
      row = []
      y = 0
      10.times do
        row.push({display: "~~", ship: false, coord: [$abc[x], y]})
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
    puts "##" + " "*51 + "##"
    puts "##" +" "*20+"BATTLESHIP "+" "*20+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
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
      boat.size.times do
        $new_game.grid[start_row][start_col][:ship] = true
        start_row += 1
      end
    # horizontal ship
    else
      start_row = (0...10).to_a.sample
      start_col = (0..x).to_a.sample
      boat.size.times do
        $new_game.grid[start_row][start_col][:ship] = true
        start_col += 1
      end
    end
    p $new_game.grid
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
    puts "##" + " "*16+"2. Resume game     "+" "*16+"##"
    puts "##" + " "*16+"3. Quit            "+" "*16+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
    # self.input = ""
    while self.input != "quit"
      self.input = gets.chomp.downcase
      if self.input == "1"
        $new_game.print_grid
        $prompt.collect_coords
      elsif self.input == "2"
        $new_game.place_ship($boat_1)
      else
        puts "Invalid response"
      end
    end
  end
# prints info/scoring box
  def info
    puts "##" + " "*51 + "##"
    puts "##" + " "*8+"Lives:      Hits:       Ships:     "+" "*8+"##"
    puts "##" + " "*51 + "##"
    puts $line_break
  end

# asks user for coordinates, prompts for row and col coords. repeats if it doesn't get correct response
  def collect_coords
    $new_game.print_grid
    self.info
    row = "z"
    while $abc.index(row) == nil
      puts "Enter row coordinate (A - J):"
      row = gets.chomp.downcase.to_s
    end
    col = ""
    while (0..9).to_a.index(col) == nil
      puts "Enter column coordinate (0 - 9):"
      col = gets.chomp.to_i
    end
    self.check_coords([row,col])
  end

  def check_coords(coord)
    lookup_cell = $new_game.grid.find{|cell| cell[:coord] == coord}
    p lookup_cell
  end

end

$new_game = GameBoard.new
$prompt = MenuPrompts.new

$prompt.welcome

binding.pry
