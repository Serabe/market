defmodule Market.Store.Calculator do
  @moduledoc false

  alias Market.Utils.Money

  defstruct [:type, :value]

  @typedoc """
  Represents the calculation of an adjustment.

  The `:type` `:get_some_free` gets as `:value` a tuple of `{quantity_to_buy, quantity_to_get_free}`,
  so `{2,1}` means that for each 3 you buy, you only pay for 2, getting 1 free.

  The `:type` `:percentage_off` gets as `:value` a tuple `{numerator, denominator}` representing a fraction
  of the price to remove. Do not set any of those numbers as negative, as the negative sign is implicit.
  """
  @type t() ::
          %__MODULE__{
            type: :get_some_free,
            value: {integer(), integer()}
          }
          | %__MODULE__{
              type: :percentage_off,
              value: {integer(), integer()}
            }

  @doc """
  Create a new calculator.
  """
  def new(opts) do
    opts = Keyword.validate!(opts, [:type, :value])

    %__MODULE__{
      type: Keyword.fetch!(opts, :type),
      value: Keyword.fetch!(opts, :value)
    }
  end

  @doc """
  Calculate the adjustment for a snapshot line.
  """
  def calculate(%__MODULE__{type: :get_some_free} = calculator, snapshot_line) do
    %{value: {quantity_to_buy, quantity_to_get_free}} = calculator
    {sku, quantity, price} = snapshot_line
    batch = quantity_to_buy + quantity_to_get_free

    batch_count = div(quantity, batch)

    {"ADJ_#{sku}", batch_count * quantity_to_get_free, Money.times(price, -1)}
  end

  def calculate(%__MODULE__{type: :percentage_off} = calculator, snapshot_line) do
    %{value: {numerator, denominator}} = calculator
    {sku, quantity, price} = snapshot_line

    total_price = Money.times(price, quantity)

    adjustment_price = Money.times(total_price, -numerator) |> Money.div(denominator)
    {"ADJ_#{sku}", 1, adjustment_price}
  end
end
