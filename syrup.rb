class Syrup
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9]

  def self.parse(io)
    char = io.getc
    case char
    when 't'
      true
    when 'f'
      false
    when *DIGITS
      self.parse_int(io, char.to_i)
    when '['
    when '{'
    when '<'
    else
      raise StandardError
    end
  end

  def self.parse_int(io, acc)
    next_char = io.getc
    while DIGITS.include?(next_char)
      acc =  acc * 10 + next_char.to_i
      next_char = io.getc
    end

    case next_char
    when '+'
      acc
    when '-'
      -acc
    when ':' # bytestring
    when "'" # symbol
    when '"' # string
      # read me acc number of bytes.
    end
  end
end
