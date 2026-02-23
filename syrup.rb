# frozen_string_literal: true

require 'byebug'
class Syrup
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze

  def self.parse(io, next_char = nil)
    raise StandardError if io.eof?

    next_char ||= io.getc

    case next_char
    when 't'
      true
    when 'f'
      false
    when *DIGITS
      parse_int(io, next_char.to_i)
    when '['
      parse_list(io)
    when '{'
      parse_dictionary(io)
    when '<'
      parse_record(io)
    else
      raise StandardError, 'invalid Syrup'
      # TODO: Write custom errors.
    end
  end

  def self.parse_record(io)
    # The label for a record is in the first position,
    # and can be any Syrup type.
    label = parse(io)

    # everything following the label are fields.
    fields = []

    next_char = io.getc
    while next_char != '>'

      fields << parse(io, next_char)
      next_char = io.getc
    end

    { label => fields }
  end

  def self.parse_dictionary(io)
    next_char = io.getc

    hash = {}
    while next_char != '}'

      case next_char
      when 't'
        hash[true] = parse(io)
      when 'f'
        hash[false] = parse(io)
      when *DIGITS
        key = parse_int(io, next_char.to_i)
        hash[key] = parse(io)
      when '['
        hash[parse_list(io)] = parse(io)
      when '<'
        key = parse_record(io)
        hash[key] = parse(io)
      end

      next_char = io.getc
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

      next_char = io.getc
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
    when '+' # positive integer
      acc
    when '-' # negative integer
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
