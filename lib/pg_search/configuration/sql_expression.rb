# frozen_string_literal: true

require 'digest'

module PgSearch
  class Configuration
    class SqlExpression
      attr_reader :weight, :name

      def initialize(expression, weight, model)
        @name = expression.to_s
        @expression = expression.to_s
        @weight = weight
        @model = model
        @connection = model.connection
      end

      def full_name
        expression
      end

      def to_sql
        expression
      end

      private

      attr_reader :expression
    end
  end
end
