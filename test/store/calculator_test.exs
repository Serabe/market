defmodule Market.Store.CalculatorTest do
  use ExUnit.Case

  alias Market.Store.Calculator

  describe "type :get_some_free" do
    test "calculates and returns an adjustment line" do
      calculator = Calculator.new(type: :get_some_free, value: {2, 1})

      snapshot_line = {"SKU-123", 8, {100, :usd}}

      # To visualise this:

      # Items:
      # X X X X X X X X
      # $ $ _ $ $ _ $ $
      # where $ is it is being paid and _ is that it is free because of the offer.

      assert Calculator.calculate(calculator, snapshot_line) == {"ADJ_SKU-123", 2, {-100, :usd}}
    end
  end

  describe "type :percentage_off" do
    test "calculates and returns an adjustment line" do
      calculator = Calculator.new(type: :percentage_off, value: {1, 3})

      snapshot_line = {"SKU-123", 4, {1123, :usd}}

      assert Calculator.calculate(calculator, snapshot_line) == {"ADJ_SKU-123", 1, {-1497, :usd}}

      # See we are doing integer division here as we cannot discount a fraction of a cent!
      snapshot_line = {"SKU-123", 4 * 3, {1123, :usd}}

      assert Calculator.calculate(calculator, snapshot_line) ==
               {"ADJ_SKU-123", 1, {-1497 * 3 - 1, :usd}}
    end
  end
end
