defmodule Market.Store.Adjustment do
  @moduledoc false

  alias Market.Store.Calculator
  alias Market.Store.Condition

  defstruct [:type, :condition, :calculator]

  @typedoc """
  Represents an adjustment. The adjustment is only applied if the condition is satisfied.
  The adjustment is applied by calling the calculator with the snapshot line.

  The only current type is `:quantity`, which bases the condition on the quantity of the
  product.

  `:condition` holds the condition to be satisfied for the adjustment to be applied.
  `:calculator` holds the calculator that will be calculating the adjustment.
  """
  @type t() :: %__MODULE__{
          type: :quantity,
          condition: Condition.t(),
          calculator: Calculator.t()
        }

  @doc """
  Create a new adjustment.
  """
  def new(opts) do
    opts = Keyword.validate!(opts, [:condition, :calculator, type: :quantity])

    %__MODULE__{
      type: Keyword.fetch!(opts, :type),
      condition: Keyword.fetch!(opts, :condition),
      calculator: Keyword.fetch!(opts, :calculator)
    }
  end

  @doc """
  Calculates the adjustment for a snapshot line. If it is applicable, returns and adjustment line
  to be added to the snapshot. Otherwise, returns `nil`.
  """
  def apply_to(%__MODULE__{type: :quantity} = adjustment, snapshot_line) do
    {_sku, quantity, _price} = snapshot_line

    if Condition.satisfies?(adjustment.condition, quantity) do
      Calculator.calculate(adjustment.calculator, snapshot_line)
    else
      nil
    end
  end
end
