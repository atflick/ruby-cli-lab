# require "pry"

$grid = []

def build_grid
  a = ["a","b","c","d","e","f","g","h","i","j"]
  x = 0
  10.times do
    row = []
    y = 0
    10.times do
      row.push({display: "~~", ship: false, coord: [a[x], y]})
      y += 1
    end
    $grid << row
    x += 1
  end
  p $grid
end

build_grid
