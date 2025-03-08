defmodule Market.Store.Price do
  @moduledoc false

  defstruct from_quantity: 0, to_quantity: :infty, value: 0, currency: :eur, tax_rate: 10

  @typedoc """
  Represents the unit price of a product if bought in a certain quantity range,
  defined by `from_quantity` and `to_quantity`.

  `tax_rate` is the tax rate in points per cents. For example, 10% tax rate would be 10.
  Included for completeness, but not used in calculations as the value already includes
  taxes.

  `value` should be expressed in the lower unit of the given `:currency`. For example,
  for euros, that would be cents (1,21 euros would be expressed as 121 in the value).
  In case of Chilean pesos, 121 pesos would be expressed as 121 in value, given
  Chilean pesos have no cents since 1984. Value includes taxes.

  `currency` is the ISO 4217 code of the currency lower cased and as atom.

  Think of `:value` and `:currency` as the Money pattern found in other languages.
  """
  @type t() :: %__MODULE__{
          from_quantity: non_neg_integer(),
          to_quantity: non_neg_integer(),
          tax_rate: non_neg_integer(),
          value: non_neg_integer(),
          currency: atom()
        }
end
