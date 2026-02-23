# frozen_string_literal: true

require_relative '../syrup'

RSpec.describe Syrup do
  it 'parses a t boolean' do
    strio = StringIO.new('t', 'r')
    expect(described_class.parse(strio)).to be true
  end

  it 'parses an f boolean' do
    strio = StringIO.new('f', 'r')
    expect(described_class.parse(strio)).to be false
  end

  it 'can parse a positive number' do
    strio = StringIO.new('123+', 'r')
    expect(described_class.parse(strio)).to be 123
  end

  it 'can parse a negative number' do
    strio = StringIO.new('123-', 'r')
    expect(described_class.parse(strio)).to be(-123)
  end

  it 'can parse string' do
    strio = StringIO.new('5"tarot', 'r')
    expect(described_class.parse(strio)).to eq 'tarot'
  end

  it 'parses strings as UTF-8' do
    strio = StringIO.new('5"tarot', 'r')
    expect(described_class.parse(strio).encoding.name).to eq 'UTF-8'
  end

  it 'can parse a symbol' do
    strio = StringIO.new("5'tarot", 'r')
    expect(described_class.parse(strio)).to eq :tarot
  end

  it 'can parse a bytestring' do
    data = 'æ'.b
    bytesize = data.bytesize # 2
    strio = StringIO.new("#{bytesize}:#{data}", 'r')
    expect(described_class.parse(strio)).to eq 'æ'.b
  end

  it 'parses bytestrings as ASCII-8BIT encoded' do
    data = 'æ'
    bytesize = data.bytesize # 2
    strio = StringIO.new("#{bytesize}:#{data}", 'r')
    expect(described_class.parse(strio).encoding.name).to eq 'ASCII-8BIT'
  end

  describe 'with flat lists of a single type' do
    # TODO: spec for parsing lists of symbols and strings together.
    # Figure out how to prevent escaping when creating the StringIO
    it 'can parse a single type, single item list' do
      list = '[t]'
      expected = [true]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end

    it 'can parse a single type, multi item list' do
      list = '[tfft]'
      expected = [true, false, false, true]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end

    it 'can parse a list of positive and negative numbers' do
      list = '[1+0+2-123+124-]'
      expected = [1, 0, -2, 123, -124]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end

    it 'can parse a list of strings' do
      cups = '4"cups'
      wands = '5"wands'
      swords = '6"swords'
      globes = '6"globes'
      list = "[#{cups}#{wands}#{swords}#{globes}]"
      expected = %w[cups wands swords globes]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end

    it 'can parse a list of symbols' do
      cups = "4'cups"
      wands = "5'wands"
      swords = "6'swords"
      globes = "6'globes"
      list = "[#{cups}#{wands}#{swords}#{globes}]"
      expected = %i[cups wands swords globes]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end

    describe 'parsing lists of bytestrings' do
      it 'can parse a list of bytestrings' do
        item1 = 'æ'.b
        item2 = 'foo'.b
        bytesize1 = item1.bytesize # 2
        bytesize2 = item2.bytesize # 3
        list = "[#{bytesize1}:#{item1}#{bytesize2}:#{item2}]"
        expected = ['æ'.b, 'foo'.b]
        strio = StringIO.new(list, 'r')
        expect(described_class.parse(strio)).to match_array(expected)
      end

      it 'parses lists of bytestrings as ASCII-8BIT encoded' do
        item1 = 'æ'.b
        item2 = 'foo'.b
        bytesize1 = item1.bytesize # 2
        bytesize2 = item2.bytesize # 3
        list = "[#{bytesize1}:#{item1}#{bytesize2}:#{item2}]"
        ['æ'.b, 'foo'.b]
        strio = StringIO.new(list, 'r')
        parsed = described_class.parse(strio)
        parsed.each do |item|
          expect(item.encoding.name).to eq 'ASCII-8BIT'
        end
      end
    end
  end

  describe 'with flat lists with multiple item types' do
    it 'can parse a list of numbers and booleans' do
      list = '[1+f2-t124-]'
      expected = [1, false, -2, true, -124]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end
  end

  describe 'with lists of lists' do
    it 'can parse nested lists' do
      list = '[t[f1+[3"foo4\'bars]]2-]'
      expected = [true, [false, 1, ['foo', :bars]], -2]
      strio = StringIO.new(list, 'r')
      expect(described_class.parse(strio)).to match_array(expected)
    end
  end

  describe 'dictionaries' do
    # TODO: implement sorting.
    it 'can parse a dictionary with a string as the key' do
      dict = '{3"age30+}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include('age' => 30)
    end

    it 'can parse a dictionary with a symbol as the key' do
      dict = '{3\'age30+}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include(age: 30)
    end

    it 'can parse a dictionary with a boolean as the key' do
      dict = '{t3"foo}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include(true => 'foo')
    end

    it 'can parse a dictionary with a list as the value' do
      dict = '{7\'numbers[1+3-]}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include(numbers: [1, -3])
    end

    it 'can parse a dictionary with a list as the key' do
      dict = '{[t]3"foo}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include([true] => 'foo')
    end

    it 'can parse nested dictionaries' do
      dict = '{3"foo{[t]3"bar}}'
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to include('foo' => { [true] => 'bar' })
    end

    it 'can parse a dictionary with a record as a key' do
      record = "<6'person30+t>"
      dict = "{#{record}f}"
      strio = StringIO.new(dict, 'r')
      expect(described_class.parse(strio)).to(
        include({ person: [30, true] } => false)
      )
    end
  end

  describe 'records' do
    # TODO: Should this be valid or no?
    it 'raises when a record is empty' do
      record = '<>'
      strio = StringIO.new(record, 'r')
      expect { described_class.parse(strio) }.to raise_error(StandardError, 'invalid Syrup')
    end

    it 'can parse a record' do
      record = "<6'person30+t>"
      # TODO: add a string to the record
      strio = StringIO.new(record, 'r')
      expected = { person: [30, true] }
      expect(described_class.parse(strio)).to eq(expected)
    end

    it 'can parse a record when the label is type dictionary' do
      dictionary = "{3'age35+}"
      record = "<#{dictionary}30+t>"
      strio = StringIO.new(record, 'r')
      expected = { { age: 35 } => [30, true] }
      expect(described_class.parse(strio)).to eq(expected)
    end

    it 'can parse a record with mixed type fields' do
      dictionary1 = "{3'age35+}"
      dictionary2 = "{3'age37+}"
      record = "<#{dictionary1}#{dictionary2}30+t>"
      strio = StringIO.new(record, 'r')
      expected = { { age: 35 } => [{ age: 37 }, 30, true] }
      expect(described_class.parse(strio)).to eq(expected)
    end
  end
end
