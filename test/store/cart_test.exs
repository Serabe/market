defmodule Market.Store.CartTest do
  use ExUnit.Case

  alias Market.Store
  alias Market.Store.Adjustment
  alias Market.Store.Calculator
  alias Market.Store.Cart
  alias Market.Store.Condition
  alias Market.Store.LineItem
  alias Market.Store.Product

  setup :basic_store

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

  describe "add_product/3" do
    test "add a quantity of a product that is not in the cart" do
      cart = Cart.new()
      cart = Cart.add_product(cart, "NESQU1K", 2)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 2
    end

    test "add a quantity of a product that is already in the cart" do
      cart = Cart.new()
      cart = Cart.add_product(cart, "NESQU1K", 2)
      cart = Cart.add_product(cart, "NESQU1K", 3)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 5
    end

    test "can add 0 of a product" do
      cart = Cart.new()
      cart = Cart.add_product(cart, "NESQU1K", 0)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 0
    end

    test "cannot add a negative quantity" do
      cart = Cart.new()

      cart = Cart.add_product(cart, "NESQU1K", 2)
      cart = Cart.add_product(cart, "NESQU1K", 3)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 5

      cart = Cart.add_product(cart, "NESQU1K", -4)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 1

      cart = Cart.add_product(cart, "NESQU1K", -4)

      assert Cart.get_product_quantity(cart, "NESQU1K") == 0
    end

    test "errors if product does not exists in the store" do
      cart = Cart.new()

      assert {:error, "Product NON_EXISTING does not exist in location MAD"} =
               Cart.add_product(cart, "NON_EXISTING", 1)
    end
  end

  describe "get_product_quantity/2" do
    test "returns 0 if the product is not in the cart" do
      cart = Cart.new()
      assert Cart.get_product_quantity(cart, "NESQU1K") == 0
    end

    test "returns the quantity of the product in the cart" do
      cart = Cart.new()
      cart = Cart.add_product(cart, "NESQU1K", 2)
      assert Cart.get_product_quantity(cart, "NESQU1K") == 2
    end
  end

  describe "get_total_price/1" do
    test "returns 0 if cart is empty" do
      cart = Cart.new()

      assert Cart.get_total_price(cart) == {0, :eur}
    end

    test "returns quantity times the unitary price if one product" do
      cart = Cart.new() |> Cart.add_product("NESQU1K", 2)

      assert Cart.get_total_price(cart) == {20, :eur}
    end

    test "takes into account bulk prices" do
      cart = Cart.new() |> Cart.add_product("NESQU1K", 12)

      assert Cart.get_total_price(cart) == {96, :eur}
    end

    test "works with several items" do
      Store.add_product(
        "MAD",
        Product.new(sku: "SPRITE", name: "Sprite", prices: %{(1..10) => 5, 11 => 4})
      )

      cart = Cart.new() |> Cart.add_product("NESQU1K", 2) |> Cart.add_product("SPRITE", 11)

      assert Cart.get_total_price(cart) == {64, :eur}
    end

    test "applies adjustment if condition is satisfied" do
      Store.add_product(
        "MAD",
        Product.new(sku: "SPRITE", name: "Sprite", prices: %{1 => 5})
      )

      Store.add_adjustment_for_product(
        "MAD",
        "SPRITE",
        Adjustment.new(
          condition: Condition.new(type: :gte, value: 5),
          calculator: Calculator.new(type: :get_some_free, value: {5, 1})
        )
      )

      cart = Cart.new() |> Cart.add_product("SPRITE", 6)

      assert Cart.get_total_price(cart) == {25, :eur}
    end

    test "applies adjustment if condition is satisfied and adjustment takes into account bulk prices" do
      Store.add_product(
        "MAD",
        Product.new(sku: "SPRITE", name: "Sprite", prices: %{(1..4) => 5, 5 => 4})
      )

      Store.add_adjustment_for_product(
        "MAD",
        "SPRITE",
        Adjustment.new(
          condition: Condition.new(type: :gte, value: 5),
          calculator: Calculator.new(type: :get_some_free, value: {5, 1})
        )
      )

      cart = Cart.new() |> Cart.add_product("SPRITE", 6)

      assert Cart.get_total_price(cart) == {20, :eur}
    end
  end

  defp basic_store(_opts) do
    start_supervised!(Market.Store)

    Market.Store.add_product(
      "MAD",
      Product.new(
        sku: "NESQU1K",
        name: "Nesquik",
        prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
      )
    )
  end
end
