defmodule Market.Store.ProductTest do
  use ExUnit.Case

  alias Market.Store.Price
  alias Market.Store.Product

  describe "new/1" do
    for required_option <- ~w(sku name prices)a do
      @required_option required_option

      test "not passing options #{@required_option} raises error" do
        assert_raise KeyError, fn ->
          opts = [
            sku: "NESQU1K",
            name: "Nesquik",
            prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
          ]

          Product.new(Keyword.delete(opts, @required_option))
        end
      end
    end

    test "returns a product with bulk prices with default currency" do
      product =
        Product.new(
          sku: "NESQU1K",
          name: "Nesquik",
          prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
        )

      assert product.sku == "NESQU1K"
      assert product.name == "Nesquik"

      assert product.prices == [
               %Price{from_quantity: 1, to_quantity: 10, value: 10, currency: :eur},
               %Price{from_quantity: 11, to_quantity: 20, value: 8, currency: :eur},
               %Price{from_quantity: 20, to_quantity: :infty, value: 7, currency: :eur}
             ]
    end

    test "returns a product with bulk prices with special currency" do
      product =
        Product.new(
          sku: "COLCAO",
          name: "Colacao",
          prices: %{(1..10) => {100, :usd}, 11 => {95, :usd}}
        )

      assert product.sku == "COLCAO"
      assert product.name == "Colacao"

      assert product.prices == [
               %Price{from_quantity: 1, to_quantity: 10, value: 100, currency: :usd},
               %Price{from_quantity: 11, to_quantity: :infty, value: 95, currency: :usd}
             ]
    end
  end

  describe "unit_price_for_quantity/2" do
    test "returns the price for a given quantity when it is in a range" do
      product =
        Product.new(
          sku: "NESQU1K",
          name: "Nesquik",
          prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
        )

      assert {10, :eur} = Product.unit_price_for_quantity(product, 5)
      assert {8, :eur} = Product.unit_price_for_quantity(product, 15)
    end

    test "returns the price for a given quantity when it is in the final range" do
      product =
        Product.new(
          sku: "NESQU1K",
          name: "Nesquik",
          prices: %{(1..10) => 10, (11..20) => 8, 20 => 7}
        )

      assert {7, :eur} = Product.unit_price_for_quantity(product, 55)
      assert {7, :eur} = Product.unit_price_for_quantity(product, 165)
    end
  end
end
