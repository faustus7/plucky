module Plucky
  module Normalizers
    class SortValue

      # Public: Initializes a Plucky::Normalizers::SortValue
      #
      # args - The hash of arguments
      #        :key_normalizer - What to use to normalize keys, must
      #                          respond to call.
      #
      def initialize(args = {})
        @key_normalizer = args.fetch(:key_normalizer) {
          raise ArgumentError, "Missing required key :key_normalizer"
        }
      end

      # Public: Given a value returns it normalized for Mongo's sort option
      def call(value)
        case value
          when Array
            if value.size == 1 && value[0].is_a?(String)
              normalized_sort_piece(value[0])
            else
              value.compact.inject({}) { |acc, v| acc.merge(normalized_sort_piece(v)) }
            end
          else
            normalized_sort_piece(value)
        end
      end

      # Private
      def normalized_sort_piece(value)
        case value
          when SymbolOperator
            normalized_direction(value.field, value.operator)
          when String
            value.split(',').inject({}) do |acc, piece|
              acc.merge(normalized_direction(*piece.split(' ')))
            end
          when Symbol
            normalized_direction(value)
          when Array
            Hash[*value]
          else
            value
        end
      end

      # Private
      def normalized_direction(field, direction=nil)
        direction ||= 'ASC'
        direction = direction.upcase == 'ASC' ? 1 : -1
        {@key_normalizer.call(field).to_s => direction}
      end
    end
  end
end
