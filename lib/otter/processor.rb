# frozen_string_literal: true

require 'csv'
require 'tempfile'

module Otter
  class Processor
    CHUNK_SIZE = 1_000

    def self.call(...) = new(...).call

    def initialize(path:, result_path:, chunk_size: CHUNK_SIZE, sort_index: 0, desc: true)
      @path = path
      @result_path = result_path
      @chunk_size = chunk_size
      @sort_index = sort_index
      @desc = desc
      @temp_files = []
    end

    def call
      process_chunks
      merge_sorted_files
      cleanup_temp_files
    end

    private

    attr_reader :path, :result_path, :chunk_size, :sort_index, :desc, :temp_files

    def process_chunks
      chunk = []
      File.foreach(@path) do |line|
        chunk << line
        if chunk.size >= @chunk_size
          process_chunk(chunk)
          chunk = []
        end
      end
      process_chunk(chunk) if chunk.any?
    end

    def process_chunk(chunk)
      @temp_files << sort_chunk(chunk).then { create_temp_file(it) }
    end

    def sort_chunk(chunk)
      chunk.map { |line| SortableRow.new(line, sort_index:, desc:) }
           .sort
           .map(&:line)
    end

    def create_temp_file(lines)
      file = Tempfile.new('otter_chunk')
      lines.each { |line| file.puts(line) }
      file.flush
      file.rewind
      file
    end

    def merge_sorted_files
      current_lines = temp_files.map(&:gets)

      File.open(@result_path, 'w') do |outfile|
        loop do
          best_index = nil
          best_sorted = nil

          current_lines.each_with_index do |line, i|
            next if line.nil?

            candidate = SortableRow.new(line, sort_index:, desc:)
            if best_sorted.nil? || candidate < best_sorted
              best_sorted = candidate
              best_index = i
            end
          end

          break if best_index.nil?

          outfile.puts(current_lines[best_index])
          current_lines[best_index] = @temp_files[best_index].gets
        end
      end
    end

    def cleanup_temp_files
      temp_files.each(&:close)
      temp_files.each(&:unlink)
    end
  end
end
