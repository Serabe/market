defmodule Market.Store.AdjustmentTest do
  use ExUnit.Case

  alias Market.Store.Adjustment
  alias Market.Store.Calculator
  alias Market.Store.Condition

  describe "new/1" do
    test "creates a new adjustment" do
      assert %Adjustment{} =
               Adjustment.new(
                 condition: Condition.new(value: 10, type: :gt),
                 calculator: Calculator.new(type: :percentage_off, value: {1, 2})
               )
    end

    test "raises error if calculator is not passed in" do
      assert_raise KeyError, fn ->
        Adjustment.new(condition: Condition.new(value: 10, type: :gt))
      end
    end

    test "raises error if condition is not passed in" do
      assert_raise KeyError, fn ->
        Adjustment.new(calculator: Calculator.new(type: :percentage_off, value: {1, 2}))
      end
    end
  end

  describe "apply_to/2" do
    test "returns nil if the condition is not satisfied" do
      adjustment =
        Adjustment.new(
          condition: Condition.new(value: 10, type: :gt),
          calculator: Calculator.new(type: :percentage_off, value: {1, 2})
        )

      assert nil == Adjustment.apply_to(adjustment, {"SKU1", 5, {10, :eur}})
    end

    test "returns the adjustment if the condition is satisfied" do
      adjustment =
        Adjustment.new(
          condition: Condition.new(value: 10, type: :gt),
          calculator: Calculator.new(type: :percentage_off, value: {1, 2})
        )

      assert {"ADJ_SKU1", 1, {-75, :eur}} ==
               Adjustment.apply_to(adjustment, {"SKU1", 15, {10, :eur}})
    end
  end
end
