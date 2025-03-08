defmodule Market.Store.Cart do
  @moduledoc false

  alias Market.Store.LineItem

  @default_cart_location_id "MAD"
  defstruct [:line_items, :location_id]

  @typedoc """
  Represents the contents of a shopping cart.

  `:line_items` is a list of line items.
  """
  @type t() :: %__MODULE__{
          line_items: list(LineItem.t()),
          location_id: String.t()
        }

  def new(opts \\ []) do
    opts = Keyword.validate!(opts, line_items: [], location_id: @default_cart_location_id)

    %__MODULE__{
      line_items: opts[:line_items],
      location_id: opts[:location_id]
    }
  end
end
