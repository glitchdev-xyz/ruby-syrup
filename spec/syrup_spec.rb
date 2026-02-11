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
end
