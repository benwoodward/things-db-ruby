require 'spec_helper'
require_relative '../things.rb'

describe '#output' do
  it 'should return a string' do
    expect(todays_tasks_as_json).to be_a(String)
  end
end
