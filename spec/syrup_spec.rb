require_relative '../syrup.rb'

RSpec.describe Syrup do
  it 'raises an error if it is not passed a file' do
    expect { Syrup.parse('not a file')  }.to raise_error
  end
  it 'parses a t boolean' do
    file = File.open(Dir.pwd + '/spec/fixtures/true.txt')
    expect(Syrup.parse(file)).to be true
  end
  it 'parses an f boolean' do
    file = File.open(Dir.pwd + '/spec/fixtures/false.txt')
    expect(Syrup.parse(file)).to be false
  end
  it 'raises an error otherwise' do
    file = File.open(Dir.pwd + '/spec/fixtures/empty.txt')
    expect { Syrup.parse(file)  }.to raise_error
  end
  it 'can parse a number' do
    file = File.open(Dir.pwd + '/spec/fixtures/number.txt')
    expect(Syrup.parse(file)).to be 12
  end
end
