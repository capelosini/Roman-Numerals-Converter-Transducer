require_relative "lib/transducer"
require_relative "lib/tester"

tests = [
  ["I", 1],
  ["II", 2],
  ["III", 3],
  ["IV", 4],
  ["V", 5],
  ["VI", 6],
  ["IX", 9],
  ["X", 10],
  ["XL", 40],
  ["XC", 90],
  ["CD", 400],
  ["CM", 900],
  ["M", 1000],
  ["XIV", 14],
  ["XXIX", 29],
  ["XLII", 42],
  ["LXXXVIII", 88],
  ["CXCIV", 194],
  ["MCMXC", 1990],
  ["MMXXIV", 2024],
  ["MMMCMXCIX", 3999], # The Maximum
  ["MCMLXXXVII", 1987], # A complex mixed one
  # Wrong ones
  ["IC", nil],
  ["VX", nil]
]

test(tests, false)

puts "\nTests Done!\n -- User Tests Section"

loop do
  print "\nWord: "
  userWord = gets
  t = DFAT.new(userWord)
  t.run()
end
