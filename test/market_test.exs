defmodule MarketTest do
  use ExUnit.Case

  alias Market.Store.Cart

  setup :start_store

  test "first test" do
    cart = create_cart("GR1,SR1,GR1,GR1,CF1")

    assert Cart.get_total_price(cart) == {2245, :gbp}
  end

  test "second test" do
    cart = create_cart("GR1,GR1")

    assert Cart.get_total_price(cart) == {311, :gbp}
  end

  test "third test" do
    cart = create_cart("SR1,SR1,GR1,SR1")

    assert Cart.get_total_price(cart) == {1661, :gbp}
  end

  test "fourth test" do
    cart = create_cart("GR1,CF1,SR1,CF1,CF1")

    assert Cart.get_total_price(cart) == {3057, :gbp}
  end

  defp start_store(_opts) do
    start_supervised!(Market.Store)
    :ok
  end

  defp create_cart(input) do
    cart = Cart.new(location_id: "LDN")

    input
    |> String.split(",", trim: true)
    |> Enum.reduce(cart, fn sku, cart -> Cart.add_product(cart, sku) end)
  end
end
