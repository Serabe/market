defmodule Market.Utils.IexUtils do
  @moduledoc """
  A module for functions to be used in IEx.
  """

  alias Market.Store.Cart
  alias Market.Utils.Money

  @doc """
  Lets the user run commands like the tests in the document.

  ```
  iex> print_price("GR1,SR1,GR1,GR1,CF1")
  £22.45
  ```
  """
  def print_price(input) do
    cart = Cart.new(location_id: "LDN")

    input
    |> String.split(",", trim: true)
    |> Enum.reduce(cart, fn sku, cart -> Cart.add_product(cart, sku) end)
    |> Cart.get_total_price()
    |> Money.format()
    |> IO.puts()
  end
end
