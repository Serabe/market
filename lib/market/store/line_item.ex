defmodule Market.Store.LineItem do
  @moduledoc false

  defstruct [:product_sku, :quantity]

  @typedoc """
  Represents a product entry in the cart.

  `:product_sku` is the stock keeping unit of the product. We don't reference
  the product in case the prices or the conditions of the product change.

  `:quantity` is the quantity of the product.
  """
  @type t() :: %__MODULE__{
          product_sku: String.t(),
          quantity: non_neg_integer()
        }

  @doc """
  Create a new line item.
  """
  def new(opts) do
    opts = Keyword.validate!(opts, [:product_sku, quantity: 1])

    %__MODULE__{
      product_sku: Keyword.fetch!(opts, :product_sku),
      quantity: opts[:quantity]
    }
  end

  @doc """
  Add quantity to a line item.
  """
  def add_quantity(line_item, qty) do
    %{line_item | quantity: line_item.quantity + qty}
  end

  @doc """
  Remove quantity from a line item.
  """
  def remove_quantity(line_item, qty) do
    %{line_item | quantity: max(0, line_item.quantity - qty)}
  end
end
