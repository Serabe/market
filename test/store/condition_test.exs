defmodule Market.Store.ConditionTest do
  use ExUnit.Case

  alias Market.Store.Condition

  describe "satisfies?/2" do
    test "checks the condition" do
      assert Condition.new(value: 10, type: :gt) |> Condition.satisfies?(11)
      refute Condition.new(value: 10, type: :gt) |> Condition.satisfies?(10)
      refute Condition.new(value: 10, type: :gt) |> Condition.satisfies?(9)

      assert Condition.new(value: 10, type: :gte) |> Condition.satisfies?(11)
      assert Condition.new(value: 10, type: :gte) |> Condition.satisfies?(10)
      refute Condition.new(value: 10, type: :gte) |> Condition.satisfies?(9)

      assert Condition.new(value: 10, type: :lt) |> Condition.satisfies?(9)
      refute Condition.new(value: 10, type: :lt) |> Condition.satisfies?(10)
      refute Condition.new(value: 10, type: :lt) |> Condition.satisfies?(11)

      assert Condition.new(value: 10, type: :lte) |> Condition.satisfies?(9)
      assert Condition.new(value: 10, type: :lte) |> Condition.satisfies?(10)
      refute Condition.new(value: 10, type: :lte) |> Condition.satisfies?(11)

      assert Condition.new(value: 10, type: :eq) |> Condition.satisfies?(10)
      refute Condition.new(value: 10, type: :eq) |> Condition.satisfies?(9)
      refute Condition.new(value: 10, type: :eq) |> Condition.satisfies?(11)

      assert Condition.new(value: 10, type: :neq) |> Condition.satisfies?(9)
      refute Condition.new(value: 10, type: :neq) |> Condition.satisfies?(10)
      assert Condition.new(value: 10, type: :neq) |> Condition.satisfies?(11)
    end
  end
end
