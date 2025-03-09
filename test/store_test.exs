defmodule Market.StoreTest do
  use ExUnit.Case

  alias Market.Store
  alias Market.Store.Price
  alias Market.Store.Product

  describe "add_product/2" do
    test "adds a product to the store for non-existing location" do
      start_supervised!(Store)

      Store.add_product(
        "MAD",
        Product.new(
          sku: "NESQU1K",
          name: "Nesquik",
          prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
        )
      )

      nesquik = Store.get_product("MAD", "NESQU1K")

      refute is_nil(nesquik)
      assert nesquik.sku == "NESQU1K"
      assert nesquik.name == "Nesquik"

      assert nesquik.prices == [
               %Price{from_quantity: 1, to_quantity: 10, value: 10, currency: :eur},
               %Price{from_quantity: 11, to_quantity: 20, value: 8, currency: :eur},
               %Price{from_quantity: 20, to_quantity: :infty, value: 7, currency: :eur}
             ]
    end

    test "overrides existing product" do
      start_supervised!(Store)

      Store.add_product(
        "MAD",
        Product.new(
          sku: "NESQU1K",
          name: "Nesquik",
          prices: %{1 => 10}
        )
      )

      nesquik = Store.get_product("MAD", "NESQU1K")
      assert nesquik.name == "Nesquik"

      Store.add_product(
        "MAD",
        Product.new(
          sku: "NESQU1K",
          name: "ColaCao",
          prices: %{1 => 10}
        )
      )

      nesquik = Store.get_product("MAD", "NESQU1K")
      assert nesquik.name == "ColaCao"
    end
  end

  describe "exist_product?/2" do
    test "returns true if the product exist in the given location" do
      start_supervised!(Store)

      Store.add_product("MAD", Product.new(sku: "NESQU1K", name: "Nesquik", prices: %{1 => 10}))

      assert Store.exist_product?("MAD", "NESQU1K")
    end

    test "returns false if the product does not exist in the given location" do
      start_supervised!(Store)

      Store.add_product("MAD", Product.new(sku: "NESQU1K", name: "Nesquik", prices: %{1 => 10}))

      assert not Store.exist_product?("BCN", "NESQU1K")
    end
  end

  describe "get_products/2" do
    test "with valid skus returns the products" do
      start_supervised!(Store)

      Store.add_product("MAD", Product.new(sku: "NESQU1K", name: "Nesquik", prices: %{1 => 10}))
      Store.add_product("MAD", Product.new(sku: "SPRITE", name: "Sprite", prices: %{1 => 1}))

      assert [%Product{sku: "NESQU1K", name: "Nesquik"}, %Product{sku: "SPRITE", name: "Sprite"}] =
               Store.get_products("MAD", ["NESQU1K", "SPRITE"])
    end

    test "if any sku is not found, do not return a value for it" do
      start_supervised!(Store)

      Store.add_product("MAD", Product.new(sku: "NESQU1K", name: "Nesquik", prices: %{1 => 10}))
      Store.add_product("MAD", Product.new(sku: "SPRITE", name: "Sprite", prices: %{1 => 1}))

      products = Store.get_products("MAD", ["NESQU1K", "RICE", "SPRITE"])

      assert Enum.count(products) == 2
      assert ~w(Nesquik Sprite) == Enum.map(products, & &1.name)
    end
  end

  describe "get_product/2" do
    test "with valid sku returns the product" do
      start_supervised!(Store)

      Store.add_product("MAD", Product.new(sku: "NESQU1K", name: "Nesquik", prices: %{1 => 10}))

      assert %Product{sku: "NESQU1K", name: "Nesquik"} = Store.get_product("MAD", "NESQU1K")
    end

    test "with invalid sku returns nil" do
      start_supervised!(Store)

      assert "MAD" |> Store.get_product("NON_EXISTENT") |> is_nil()
    end
  end
end
