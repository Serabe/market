defmodule Market.Store.CartTest do
  use ExUnit.Case

  alias Market.Store.Cart
  alias Market.Store.LineItem

  describe "new/1" do
    test "add default line_items" do
      cart = Cart.new()
      assert cart.line_items == []
    end

    test "add default location id" do
      cart = Cart.new()

      assert cart.location_id == "MAD"
    end

    test "options can be passed in" do
      cart =
        Cart.new(
          line_items: [LineItem.new(product_sku: "NESQU1K", quantity: 1)],
          location_id: "BCN"
        )

      assert cart.location_id == "BCN"
      assert cart.line_items == [LineItem.new(product_sku: "NESQU1K", quantity: 1)]
    end
  end
end
