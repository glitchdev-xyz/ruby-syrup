require 'byebug'
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
      self.parse_list(io)
    when '{'
    when '<'
    else
      raise StandardError
    end
  end

  def self.parse_list(io)
    next_char = io.getc
    list = []
    while next_char != ']'
      case next_char
      when 't'
        list << true
      when 'f'
        list  << false
      when *DIGITS
       list << self.parse_int(io, next_char.to_i)
        # when '['
        #   self.parse_list(io)
        # when '{'
        # when '<'
        # else
        #   raise StandardError
      end

      next_char = io.getc
    end

    list
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
      io.read(acc)
    when "'" # symbol
      io.read(acc).to_sym
    when '"' # string
      io.read(acc).encode!('UTF-8')
    end
  end
end
