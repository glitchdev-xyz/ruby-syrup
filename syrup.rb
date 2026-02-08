class Syrup
  def self.parse(io)
    raise StandardError unless io.is_a?(File)
    char = io.getc
    case char
    when 't'
      true
    when 'f'
      false
    when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      self.parse_int(io, char.to_i)
    else
      raise StandardError
    end
  end

  def self.parse_int(io, acc)
    # look at the next char in the io
    # if it's another digit, glom it on to the previous digit(s)
    next_char = io.getc
    case next_char
    when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      self.parse_int(io, acc * 10 + next_char.to_i)
    when '+'
      acc
    when '-'
      -acc
    end

  end
end
