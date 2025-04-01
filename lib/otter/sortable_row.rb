# frozen_string_literal: true

module Otter
  class SortableRow
    include Comparable
    attr_reader :line

    def initialize(line, sort_index:, desc: true)
      @line = line.chomp
      fields = CSV.parse_line(@line) || []
      value = fields[sort_index] || ''
      @key = numeric?(value) ? value.to_f : value.to_s
      @desc = desc
    end

    def <=>(other)
      cmp = if numeric?(key) && numeric?(other.key)
              key <=> other.key
            else
              key.to_s <=> other.key.to_s
            end
      desc ? -cmp : cmp
    end

    protected

    attr_reader :key

    private

    attr_reader :sort_index, :desc

    def numeric?(value) = value.to_s.match?(/\A-?\d+(\.\d+)?\z/)
  end
end
