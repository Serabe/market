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

  describe "add_quantity/2" do
    test "can add any quantity" do
      line_item = LineItem.new(product_sku: "NESQU1K", quantity: 1)

      line_item = LineItem.add_quantity(line_item, 2)

      assert line_item.quantity == 3
    end
  end

  describe "remove_quantity/2" do
    test "can remove any quantity" do
      line_item = LineItem.new(product_sku: "NESQU1K", quantity: 3)

      line_item = LineItem.remove_quantity(line_item, 1)

      assert line_item.quantity == 2
    end

    test "cannot remove more than the quantity" do
      line_item = LineItem.new(product_sku: "NESQU1K", quantity: 3)

      line_item = LineItem.remove_quantity(line_item, 4)

      assert line_item.quantity == 0
    end
  end
end
