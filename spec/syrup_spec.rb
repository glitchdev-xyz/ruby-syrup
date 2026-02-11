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
  it 'can parse a symbol' do
    strio = StringIO.new("5'tarot", 'r')
    expect(Syrup.parse(strio)).to eq 'tarot'
  end
  it 'can parse a bytestring' do
    data = "æ".b
    bytesize = data.bytesize # 2
    strio = StringIO.new("#{bytesize}:#{data}", 'r')
    expect(Syrup.parse(strio)).to eq 'æ'.b
  end
end
