require 'spec_helper'
require_relative '../things.rb'

describe '#output' do
  it 'should return a string' do
    expect(gist_content).to be_a(String)
  end
end
