require 'spec_helper'
require_relative '../things.rb'
require 'json'

describe '#gist_content' do
  it 'should return a string' do
    expect(gist_content).to be_a(String)
  end

  it 'should be in JSON format' do
    json = JSON.parse gist_content
    expect(json.first.keys).to include('things_url', 'content', 'duration')
  end
end

describe '#arranged_tasks' do
  it 'should be an array of Task objects' do
    tasks = arranged_tasks
    expect(tasks).to be_an(Array)
    expect(tasks.first).to be_an_instance_of(Task)
  end
end
