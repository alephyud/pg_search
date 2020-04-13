# frozen_string_literal: true

require "pg_search/configuration/association"
require "pg_search/configuration/column"
require "pg_search/configuration/foreign_column"
require "pg_search/configuration/sql_expression"

module PgSearch
  class Configuration
    attr_reader :model

    def initialize(options, model)
      @options = default_options.merge(options)
      @model = model

      assert_valid_options(@options)
    end

    class << self
      def alias(*strings)
        name = Array(strings).compact.join("_")
        # By default, PostgreSQL limits names to 32 characters, so we hash and limit to 32 characters.
        "pg_search_#{Digest::SHA2.hexdigest(name)}".first(32)
      end
    end

    def columns
      regular_columns + sql_expressions + associated_columns
    end

    def regular_columns
      return [] unless options[:against]

      Array(options[:against]).map do |column_name, weight|
        Column.new(column_name, weight, model)
      end
    end

    def sql_expressions
      return [] unless options[:against_sql]

      Array(options[:against_sql]).map do |expression, weight|
        SqlExpression.new(expression, weight, model)
      end
    end

    def associations
      return [] unless options[:associated_against]

      options[:associated_against].map do |association, column_names|
        Association.new(model, association, column_names)
      end.flatten
    end

    def associated_columns
      associations.map(&:columns).flatten
    end

    def query
      options[:query].to_s
    end

    def ignore
      Array(options[:ignoring])
    end

    def ranking_sql
      options[:ranked_by]
    end

    def features
      Array(options[:using])
    end

    def feature_options
      @feature_options ||= {}.tap do |hash|
        features.map do |feature_name, feature_options|
          hash[feature_name] = feature_options
        end
      end
    end

    def order_within_rank
      options[:order_within_rank]
    end

    private

    attr_reader :options

    def default_options
      { using: :tsearch }
    end

    VALID_KEYS = %w[
      against ranked_by ignoring using query associated_against order_within_rank against_sql
    ].map(&:to_sym)

    VALID_VALUES = {
      ignoring: [:accents]
    }.freeze

    def assert_valid_options(options)
      unless options[:against] || options[:associated_against] || options[:against_sql]
        raise ArgumentError,
              "the search scope #{@name} must have :against, :associated_against or :against_sql in its options"
      end

      options.assert_valid_keys(VALID_KEYS)

      VALID_VALUES.each do |key, values_for_key|
        Array(options[key]).each do |value|
          raise ArgumentError, ":#{key} cannot accept #{value}" unless values_for_key.include?(value)
        end
      end
    end
  end
end
