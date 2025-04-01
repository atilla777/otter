# frozen_string_literal: true

# spec/sortable_row_spec.rb
require 'csv'

RSpec.describe Otter::SortableRow do
  describe 'numeric value comparisons' do
    context 'when sorting in ascending order' do
      it 'orders numeric keys correctly (smaller numbers come first)' do
        row1 = described_class.new('10,some text', sort_index: 0, desc: false)
        row2 = described_class.new('2,some text', sort_index: 0, desc: false)
        expect(row2).to be < row1
      end
    end

    context 'when sorting in descending order' do
      it 'orders numeric keys correctly (larger numbers come first)' do
        row1 = described_class.new('10,some text', sort_index: 0, desc: true)
        row2 = described_class.new('2,some text', sort_index: 0, desc: true)
        expect(row1).to be < row2
      end
    end
  end

  describe 'string value comparisons' do
    context 'when sorting in ascending order' do
      it 'orders alphabetic strings correctly' do
        row_a = described_class.new('apple,color', sort_index: 0, desc: false)
        row_b = described_class.new('banana,color', sort_index: 0, desc: false)
        expect(row_a).to be < row_b # "apple" comes before "banana"
      end
    end

    context 'when sorting in descending order' do
      it 'orders alphabetic strings correctly' do
        row_a = described_class.new('apple,color', sort_index: 0, desc: true)
        row_b = described_class.new('banana,color', sort_index: 0, desc: true)
        expect(row_b).to be < row_a
      end
    end
  end
end
