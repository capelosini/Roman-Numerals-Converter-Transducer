require 'set'


class DFAT # Deterministic Finite Automaton Transducer
  def initialize(word)
    @word = word.upcase.strip
    @alphabet = Set[:I, :V, :X, :L, :C, :D, :M, :""]
    setup()
  end

  def setup
    @index = 0
    @max = @word.size
    @result = 0
  end

  def next_sym
    @index >= @max ? :"" : @word[@index].to_sym
  end

  def run(silent=false)
    setup()
    state = "q0"

    puts "\n\n----------\nMachine started in state: " + state unless silent

    loop do
      symbol = next_sym

      unless @alphabet.include?(symbol)
        puts "Error: '#{symbol}' is not a valid Roman numeral."
        return nil
      end

      case [symbol, state]

      # --- THOUSANDS (M) ---
      in [:M, "q0"]   then @result += 1000; state = "qM"
      in [:M, "qM"]   then @result += 1000; state = "qMM"
      in [:M, "qMM"]  then @result += 1000; state = "qMMM"

      # --- HUNDREDS (C, D, M) ---
      in [:C, "q0"] | [:C, "qM"] | [:C, "qMM"] | [:C, "qMMM"]
        @result += 100; state = "qC"
      in [:D, "q0"] | [:D, "qM"] | [:D, "qMM"] | [:D, "qMMM"]
        @result += 500; state = "qD"

      in [:C, "qC"]   then @result += 100; state = "qCC"
      in [:C, "qCC"]  then @result += 100; state = "qCCC"

      # Subtractive Hundreds
      in [:D, "qC"]   then @result += 300; state = "q_sub_h" # CD (100 + 300 = 400)
      in [:M, "qC"]   then @result += 800; state = "q_sub_h" # CM (100 + 800 = 900)

      # --- TENS (X, L, C) ---
      in [:X, "q0"] | [:X, "qM"] | [:X, "qL"] | [:X, "qMM"] | [:X, "qMMM"] | [:X, "qC"] | [:X, "qCC"] | [:X, "qCCC"] | [:X, "qD"] | [:X, "q_sub_h"]
        @result += 10; state = "qX"

      in [:L, "q0"] | [:L, "qM"] | [:L, "qMM"] | [:L, "qMMM"] | [:L, "qC"] | [:L, "qCC"] | [:L, "qCCC"] | [:L, "qD"] | [:L, "q_sub_h"]
        @result += 50; state = "qL"

      in [:X, "qX"]   then @result += 10; state = "qXX"
      in [:X, "qXX"]  then @result += 10; state = "qXXX"

      # Subtractive Tens
      in [:L, "qX"]   then @result += 30; state = "q_sub_t" # XL (10 + 30 = 40)
      in [:C, "qX"]   then @result += 80; state = "q_sub_t" # XC (10 + 80 = 90)

      # --- ONES (I, V, X) ---
      in [:I, "q0"] | [:I, "qV"] | [:I, "qM"] | [:I, "qMM"] | [:I, "qMMM"] | [:I, "qC"] | [:I, "qCC"] | [:I, "qCCC"] | [:I, "qD"] | [:I, "q_sub_h"] | [:I, "qX"] | [:I, "qXX"] | [:I, "qXXX"] | [:I, "qL"] | [:I, "q_sub_t"]
        @result += 1; state = "qI"

      in [:V, "q0"] | [:V, "qM"] | [:V, "qMM"] | [:V, "qMMM"] | [:V, "qC"] | [:V, "qCC"] | [:V, "qCCC"] | [:V, "qD"] | [:V, "q_sub_h"] | [:V, "qX"] | [:V, "qXX"] | [:V, "qXXX"] | [:V, "qL"] | [:V, "q_sub_t"]
        @result += 5; state = "qV"

      in [:I, "qI"]   then @result += 1; state = "qII"
      in [:I, "qII"]  then @result += 1; state = "qIII"

      # Subtractive Ones
      in [:V, "qI"]   then @result += 3; state = "q_final" # IV (1 + 3 = 4)
      in [:X, "qI"]   then @result += 8; state = "q_final" # IX (1 + 8 = 9)

      # --- Acceptance ---
      in [:"", _]
        puts "Accepted!" unless silent
        break

      else
        puts "Invalid sequence or state not handled: #{symbol} after #{state}"
        return nil
      end

      @index += 1
      puts "Read: #{symbol} | Result: #{@result} | New State: #{state}" unless silent
    end

    puts "Input: #{@word} | Final Result: #{@result}" unless silent

    return @result
  end
end
