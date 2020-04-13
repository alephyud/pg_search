# frozen_string_literal: true

require "spec_helper"

describe PgSearch::Configuration::SqlExpression do
  describe "#to_sql" do
    with_model :Model do
      table do |t|
        t.string :name
        t.integer :number
      end
    end

    it "returns the sql expression as given" do
      column = described_class.new("name || ' ' || number::string", nil, Model)
      expect(column.to_sql).to eq("name || ' ' || number::string")
    end
  end
end
