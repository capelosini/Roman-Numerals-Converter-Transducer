require_relative "transducer"

def test(tests, silent=true)
  success = 0
  failed = 0
  tests.each do |input, expected|
    transducer = DFAT.new(input)
    res = transducer.run(silent)
    if res == expected
      puts "  [SUCCESS] Test '#{input}' passed!"
      success += 1
    else
      puts "  [ERROR] Test '#{input}' not passed!\nExpected: #{expected}\nGot: #{res}"
      failed += 1
    end
  end
  puts "\nSuccess: #{success}\nFail: #{failed}"
end
