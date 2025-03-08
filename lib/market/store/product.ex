defmodule Market.Store.Product do
  @moduledoc false

  alias Market.Store.Price

  defstruct [:sku, :name, :prices]

  @typedoc """
  Represents a product in the store.

  `:sku` is the stock keeping unit of the product (the identifier used by the store).

  `:name` is the user-facing name of the product.

  `:prices` is a list of prices for the product.
  """
  @type t() :: %__MODULE__{
          sku: String.t(),
          name: String.t(),
          prices: list(Price.t())
        }

  @doc """
  Creates a new product.
  Requires `:sku`, `:name` and `:prices` options. `:sku` and `:name` are strings
  and documented on the `Market.Store.Product.t/0`. For `:prices`, a map is expected
  such as:

  - Keys are either an integer, in which case is considered that all quantities above that
    amount is given that price, or a range, in which case the price is given for any quantity
    between both values included.
  - Values are either a single integer, in which case is the price in the default currency (euros
    as the time of this writing) or a tuple `{value, currency}`. Refer to `Market.Store.Price.t/0`
    for more information.
  """
  def new(opts) do
    opts = Keyword.validate!(opts, [:sku, :name, :prices])

    %__MODULE__{
      sku: Keyword.fetch!(opts, :sku),
      name: Keyword.fetch!(opts, :name),
      prices: opts |> Keyword.fetch!(:prices) |> build_prices()
    }
  end

  defp build_prices(prices) when is_map(prices) do
    prices
    |> Enum.map(fn
      {quantity, {value, currency}} when is_integer(quantity) ->
        %Price{from_quantity: quantity, value: value, currency: currency}

      {quantity, value} when is_integer(quantity) ->
        %Price{from_quantity: quantity, value: value}

      {from_quantity..to_quantity//__step, {value, currency}}
      when is_integer(from_quantity) and is_integer(to_quantity) ->
        %Price{
          from_quantity: from_quantity,
          to_quantity: to_quantity,
          value: value,
          currency: currency
        }

      {from_quantity..to_quantity//_step, value}
      when is_integer(from_quantity) and is_integer(to_quantity) ->
        %Price{from_quantity: from_quantity, to_quantity: to_quantity, value: value}
    end)
    |> Enum.sort_by(& &1.from_quantity)
  end
end
