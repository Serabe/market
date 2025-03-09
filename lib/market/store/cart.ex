defmodule Market.Store.Cart do
  @moduledoc false

  alias Market.Store
  alias Market.Store.LineItem
  alias Market.Utils.Money

  @default_cart_location_id "MAD"
  defstruct [:line_items, :location_id, snapshot: []]

  @typedoc """
  Represents the contents of a shopping cart.

  - `:line_items` is a list of line items.
  - `:location_id` is the location id to where to take the items from.
  - `:snapshot` is a list of tuples with the sku, quantity and price of
    the product in the current time.  The intention of this snapshot is
    so we can add in features related to changes in product or prices.

  """
  @type t() :: %__MODULE__{
          line_items: list(LineItem.t()),
          location_id: String.t(),
          snapshot: list({String.t(), non_neg_integer(), non_neg_integer()})
        }

  @doc """
  Create a new cart.
  """
  def new(opts \\ []) do
    opts = Keyword.validate!(opts, line_items: [], location_id: @default_cart_location_id)

    %__MODULE__{
      line_items: opts[:line_items],
      location_id: opts[:location_id]
    }
    |> update_snapshot()
  end

  @doc """
  Add a line item to the cart.
  """
  def add_product(cart, sku, qty \\ 1) do
    if check_product_exist(cart, sku) do
      cart
      |> update_product_in_cart(sku, &Map.put(&1, :quantity, &1.quantity + qty))
      |> update_snapshot()
    else
      {:error, "Product #{sku} does not exist in location #{cart.location_id}"}
    end
  end

  @doc """
  Get the quantity of a product in the cart.
  """
  def get_product_quantity(cart, sku) do
    cart.line_items |> Enum.find(%{}, &(&1.product_sku == sku)) |> Map.get(:quantity, 0)
  end

  @doc """
  Get total.
  """
  def get_total_price(%__MODULE__{line_items: []} = _cart), do: {0, :eur}

  def get_total_price(%__MODULE__{} = cart) do
    [{_, qty, price} | rest] = cart.snapshot

    Enum.reduce(rest, Money.times(price, qty), fn {_, qty, price}, acc ->
      Money.sum(acc, Money.times(price, qty))
    end)
  end

  @doc """
  Update the snapshot of the cart.
  """
  def update_snapshot(%__MODULE__{line_items: []} = cart) do
    %{cart | snapshot: []}
  end

  def update_snapshot(%__MODULE__{} = cart) do
    items = Enum.map(cart.line_items, &{&1.product_sku, &1.quantity})

    snapshot = Store.get_snapshot(cart.location_id, items)

    # In here, we could calculate changes in prices or products.
    %{
      cart
      | snapshot: snapshot,
        line_items: modify_line_items_with_snapshot(cart.line_items, snapshot)
    }
  end

  defp modify_line_items_with_snapshot(line_items, snapshot) do
    snapshot_map =
      Map.new(snapshot, fn {sku, qty, price} ->
        {sku, %{qty: qty, price: price}}
      end)

    Enum.map(line_items, fn line_item ->
      case Map.get(snapshot_map, line_item.product_sku) do
        nil ->
          line_item

        %{qty: qty} ->
          %{line_item | quantity: qty}
      end
    end)
  end

  defp update_product_in_cart(cart, sku, func) do
    new_line_items =
      case Enum.find_index(cart.line_items, &(&1.product_sku == sku)) do
        nil ->
          [LineItem.new(product_sku: sku, quantity: 0) | cart.line_items]
          |> List.update_at(0, func)

        index ->
          List.update_at(cart.line_items, index, func)
      end

    %{cart | line_items: post_process_line_items(new_line_items)}
  end

  defp post_process_line_items(new_line_items) do
    new_line_items
    |> Enum.map(fn line_item ->
      %{line_item | quantity: max(0, line_item.quantity)}
    end)
    |> Enum.reject(fn line_item -> line_item.quantity == 0 end)
  end

  defp check_product_exist(%__MODULE__{} = cart, product_sku) do
    Store.exist_product?(cart.location_id, product_sku)
  end
end
