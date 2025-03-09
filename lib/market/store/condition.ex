defmodule Market.Store.Condition do
  @moduledoc false

  defstruct [:value, :type]

  @typedoc """
  Represents a condition. For example, the condition :lt(10) means being less than 10.

  Why modeling it this way like this and not like a function, you may ask? Because this
  can be easily be moved to a database.

  - `:type` can be `:gt` (greater than), `:gte` (greater than or equal), `:lt` (less than),
    `:lte` (less than or equal), `:eq` (equal), `:neq` (not equal).
  - `:value` is the value to compare against.
  """
  @type t() :: %__MODULE__{
          value: non_neg_integer(),
          type: :gt | :gte | :lt | :lte | :eq | :neq
        }

  @doc """
  Create a new condition.
  """
  def new(opts) do
    opts = Keyword.validate!(opts, [:value, type: :eq])

    %__MODULE__{
      value: Keyword.fetch!(opts, :value),
      type: Keyword.fetch!(opts, :type)
    }
  end

  @doc """
  Check if a condition is satisfied by a value.
  """
  def satisfies?(%__MODULE__{type: :gt, value: value}, x), do: x > value
  def satisfies?(%__MODULE__{type: :gte, value: value}, x), do: x >= value
  def satisfies?(%__MODULE__{type: :lt, value: value}, x), do: x < value
  def satisfies?(%__MODULE__{type: :lte, value: value}, x), do: x <= value
  def satisfies?(%__MODULE__{type: :eq, value: value}, x), do: x == value
  def satisfies?(%__MODULE__{type: :neq, value: value}, x), do: x != value
end
