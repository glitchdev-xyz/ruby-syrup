# frozen_string_literal: true

require 'byebug'
class Syrup
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze

  def self.parse(io)
    char = io.getc

    case char
    when 't'
      true
    when 'f'
      false
    when *DIGITS
      parse_int(io, char.to_i)
    when '['
      parse_list(io)
    when '{'
      parse_dictionary(io)
    when '<'
    else
      raise StandardError
    end
  end

  def self.parse_dictionary(io)
    next_char = io.getc
    hash = {}

    while next_char != '}'
      case next_char
      when 't'
        key = true
        value = parse(io)
        hash[key] = value
      when 'f'
        key = false
        value = parse(io)
        hash[key] = value
      when *DIGITS
        key = parse_int(io, next_char.to_i)
        value = parse(io)
        hash[key] = value
      when '['
        key = parse_list(io)
        value = parse(io)
        hash[key] = value
      end

      next_char = io.getc unless io.eof?
    end

    hash
  end

  def self.parse_list(io)
    next_char = io.getc
    arr = []
    while next_char != ']'
      case next_char
      when 't'
        arr << true
      when 'f'
        arr << false
      when *DIGITS
        arr << parse_int(io, next_char.to_i)
      when '['
        arr << parse_list(io)
      end
      next_char = io.getc unless io.eof?
    end

    arr
  end

  def self.parse_int(io, acc)
    next_char = io.getc
    while DIGITS.include?(next_char)
      acc = (acc * 10) + next_char.to_i
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
