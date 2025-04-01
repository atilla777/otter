# frozen_string_literal: true

# spec/processor_spec.rb
require 'tempfile'
require 'fileutils'
require 'tmpdir'

RSpec.describe Otter::Processor do
  let(:input_csv) do
    <<~CSV
      z, 5
      x, 3
      a, 7
      c, 1
      z, 5
      x, 3
      a, 8
      n, 1
    CSV
  end

  let(:input_file) { Tempfile.new('input.csv') }
  let(:output_dir) { Dir.mktmpdir }
  let(:output_file_path) { File.join(output_dir, 'result.csv') }

  before do
    input_file.write(input_csv)
    input_file.rewind
  end

  after do
    input_file.close
    input_file.unlink
    FileUtils.remove_entry(output_dir) if File.directory?(output_dir)
  end

  it 'sorts the CSV file in descending order (default) by the specified index' do
    processor = Otter::Processor.new(
      path: input_file.path,
      result_path: output_file_path,
      sort_index: 0,
      chunk_size: 2
    )
    processor.call

    result_lines = File.readlines(output_file_path).map(&:chomp)
    expected = ['z, 5', 'z, 5', 'x, 3', 'x, 3', 'n, 1', 'c, 1', 'a, 7', 'a, 8']
    expect(result_lines).to eq(expected)
  end

  it 'sorts the CSV file in ascending order when specified' do
    processor = Otter::Processor.new(
      path: input_file.path,
      result_path: output_file_path,
      sort_index: 0,
      chunk_size: 2,
      desc: false
    )
    processor.call

    result_lines = File.readlines(output_file_path).map(&:chomp)
    expected = ['a, 7', 'a, 8', 'c, 1', 'n, 1', 'x, 3', 'x, 3', 'z, 5', 'z, 5']
    expect(result_lines).to eq(expected)
  end

  it 'allows invocation via the class method .call' do
    Otter::Processor.call(
      path: input_file.path,
      result_path: output_file_path,
      sort_index: 0,
      chunk_size: 2
    )
    result_lines = File.readlines(output_file_path).map(&:chomp)
    expected = ['z, 5', 'z, 5', 'x, 3', 'x, 3', 'n, 1', 'c, 1', 'a, 7', 'a, 8']
    expect(result_lines).to eq(expected)
  end
end
