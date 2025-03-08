defmodule Market.Store.LineItemTest do
  use ExUnit.Case

  alias Market.Store.LineItem

  describe "new/1" do
    test "raises an error if product_sku is not provided" do
      assert_raise KeyError, fn ->
        LineItem.new(quantity: 1)
      end
    end

    test "quantity defaults to 1" do
      line_item = LineItem.new(product_sku: "NESQU1K")
      assert line_item.quantity == 1
    end

    test "quantity can be overridden" do
      line_item = LineItem.new(product_sku: "NESQU1K", quantity: 2)
      assert line_item.quantity == 2
    end
  end
end
