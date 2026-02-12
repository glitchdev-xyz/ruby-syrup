require_relative '../syrup.rb'

RSpec.describe Syrup do
  it 'parses a t boolean' do
    strio = StringIO.new('t', 'r')
    expect(Syrup.parse(strio)).to be true
  end
  it 'parses an f boolean' do
    strio = StringIO.new('f', 'r')
    expect(Syrup.parse(strio)).to be false
  end
  it 'can parse a positive number' do
    strio = StringIO.new('123+', 'r')
    expect(Syrup.parse(strio)).to be 123
  end
  it 'can parse a negative number' do
    strio = StringIO.new('123-', 'r')
    expect(Syrup.parse(strio)).to be -123
  end
  it 'can parse string' do
    strio = StringIO.new('5"tarot', 'r')
    expect(Syrup.parse(strio)).to eq 'tarot'
  end
  it 'parses strings as UTF-8' do
    strio = StringIO.new('5"tarot', 'r')
    expect(Syrup.parse(strio).encoding.name).to eq 'UTF-8'
  end
  it 'can parse a symbol' do
    strio = StringIO.new("5'tarot", 'r')
    expect(Syrup.parse(strio)).to eq :tarot
  end
  it 'can parse a bytestring' do
    data = "æ".b
    bytesize = data.bytesize # 2
    strio = StringIO.new("#{bytesize}:#{data}", 'r')
    expect(Syrup.parse(strio)).to eq 'æ'.b
  end
  it 'parses bytestrings as ASCII-8BIT encoded' do
    data = "æ"
    bytesize = data.bytesize # 2
    strio = StringIO.new("#{bytesize}:#{data}", 'r')
    expect(Syrup.parse(strio).encoding.name).to eq 'ASCII-8BIT'
  end
  describe 'with flat lists of a single type' do
    it 'can parse a single type, single item list' do
      list = '[t]'
      expected = [true]
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)
    end
    it 'can parse a single type, multi item list' do
      list = '[tfft]'
      expected = [true, false, false, true]
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)
    end
    it 'can parse a list of positive and negative numbers' do
      list = '[1+0+2-123+124-]'
      expected = [1, 0, -2, 123, -124]
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)
    end
    it 'can parse a list of strings' do
      cups = '4"cups'
      wands = '5"wands'
      swords = '6"swords'
      globes = '6"globes'
      list = "[#{cups}#{wands}#{swords}#{globes}]"
      expected = ['cups', 'wands', 'swords', 'globes']
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)
    end
    it 'can parse a list of symbols' do
      cups = "4'cups"
      wands = "5'wands"
      swords = "6'swords"
      globes = "6'globes"
      list = "[#{cups}#{wands}#{swords}#{globes}]"
      expected = [:cups, :wands, :swords, :globes]
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)

    end
    describe 'parsing lists of bytestrings' do
      it 'can parse a list of bytestrings' do
        item_1 = "æ".b
        item_2 = "foo".b
        bytesize_1 = item_1.bytesize # 2
        bytesize_2 = item_2.bytesize # 3
        list = "[#{bytesize_1}:#{item_1}#{bytesize_2}:#{item_2}]"
        expected = ['æ'.b, 'foo'.b]
        strio = StringIO.new(list, 'r')
        expect(Syrup.parse(strio)).to match_array(expected)
      end
      it 'parses lists of bytestrings as ASCII-8BIT encoded' do
        item_1 = "æ".b
        item_2 = "foo".b
        bytesize_1 = item_1.bytesize # 2
        bytesize_2 = item_2.bytesize # 3
        list = "[#{bytesize_1}:#{item_1}#{bytesize_2}:#{item_2}]"
        expected_list = ['æ'.b, 'foo'.b]
        strio = StringIO.new(list, 'r')
        parsed = Syrup.parse(strio)
        expect(parsed[0].encoding.name).to eq 'ASCII-8BIT'
        expect(parsed[1].encoding.name).to eq 'ASCII-8BIT'
      end
    end
  end
  describe 'with flat lists with multiple item types' do
    it 'can parse a list of numbers and booleans' do
      list = '[1+f2-t124-]'
      expected = [1, false, -2, true, -124]
      strio = StringIO.new(list, 'r')
      expect(Syrup.parse(strio)).to match_array(expected)
    end
  end
end
