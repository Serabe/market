defmodule Market.Store do
  @moduledoc """
  The Store module is responsible for managing the state of a store.

  A store would be a mix of a DB and a location in our chain of supermarkets.
  """

  use GenServer

  alias Market.Store.Adjustment
  alias Market.Store.Calculator
  alias Market.Store.Condition
  alias Market.Store.Product

  ### Client API

  def add_adjustment_for_product(location_id, product_sku, %Adjustment{} = adjustment) do
    :ok =
      GenServer.cast(
        __MODULE__,
        {:add_adjustment_for_product, location_id, product_sku, adjustment}
      )
  end

  @doc """
  Add a product to the store database for a given location.
  """
  def add_product(location_id, %Product{} = product) do
    :ok = GenServer.cast(__MODULE__, {:add_product, location_id, product})
  end

  @doc """
  Check if a product exists in the store database for a given location.
  """
  def exist_product?(location_id, product_sku) do
    GenServer.call(__MODULE__, {:exist_product, location_id, product_sku})
  end

  @doc """
  Get a product from the store database for a given location.
  """
  def get_product(location_id, sku) do
    location_id |> get_products([sku]) |> List.first()
  end

  @doc """
  Get a list of products from the store database for a given location.
  """
  def get_products(location_id, skus) when is_list(skus) do
    GenServer.call(__MODULE__, {:get_products, location_id, skus})
  end

  @doc false
  def get_snapshot(location_id, list_of_skus_and_quantities)
      when is_list(list_of_skus_and_quantities) do
    GenServer.call(__MODULE__, {:get_snapshot, location_id, list_of_skus_and_quantities})
  end

  #### GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    state =
      %{}
      |> add_product(
        "LDN",
        Product.new(sku: "GR1", name: "Green tea", prices: %{1 => {311, :gbp}})
      )
      |> add_product(
        "LDN",
        Product.new(
          sku: "SR1",
          name: "Strawberries",
          prices: %{(1..2) => {500, :gbp}, 3 => {450, :gbp}}
        )
      )
      |> add_product("LDN", Product.new(sku: "CF1", name: "Coffee", prices: %{1 => {1123, :gbp}}))
      |> add_adjustment(
        "LDN",
        "GR1",
        Adjustment.new(
          condition: Condition.new(type: :gte, value: 1),
          calculator: Calculator.new(type: :get_some_free, value: {1, 1})
        )
      )
      |> add_adjustment(
        "LDN",
        "CF1",
        Adjustment.new(
          condition: Condition.new(type: :gte, value: 3),
          calculator: Calculator.new(type: :percentage_off, value: {1, 3})
        )
      )

    {:ok, state}
  end

  def handle_cast(
        {:add_adjustment_for_product, location_id, product_sku, %Adjustment{} = adjustment},
        state
      ) do
    {:noreply, add_adjustment(state, location_id, product_sku, adjustment)}
  end

  def handle_cast({:add_product, location_id, %Product{} = product}, state) do
    {:noreply, add_product(state, location_id, product)}
  end

  def handle_call({:exist_product, location_id, product_sku}, _from, state) do
    exists? = state |> get_products_for_location(location_id) |> Map.has_key?(product_sku)
    {:reply, exists?, state}
  end

  def handle_call({:get_products, location_id, skus}, _from, state) do
    location_db = get_products_for_location(state, location_id)

    products =
      skus |> List.wrap() |> Enum.map(&Map.get(location_db, &1, nil)) |> Enum.reject(&is_nil/1)

    {:reply, products, state}
  end

  def handle_call({:get_snapshot, location_id, list_of_skus_and_quantities}, _from, state) do
    products_db = get_products_for_location(state, location_id)

    snapshot =
      Enum.map(list_of_skus_and_quantities, fn {sku, quantity} ->
        case Map.get(products_db, sku) do
          nil ->
            {sku, quantity, nil}

          product ->
            price = Product.unit_price_for_quantity(product, quantity)
            {sku, quantity, price}
        end
      end)

    adjustments_db = get_adjustments_for_location(state, location_id)

    adjustment_lines =
      Enum.flat_map(snapshot, fn snapshot_line ->
        {sku, _qty, _price} = snapshot_line

        adjustments_db
        |> Map.get(sku, [])
        |> Enum.map(fn adjustment ->
          Adjustment.apply_to(adjustment, snapshot_line)
        end)
        |> Enum.reject(&is_nil/1)
      end)

    {:reply, snapshot ++ adjustment_lines, state}
  end

  defp add_adjustment(state, location_id, product_sku, adjustment) do
    update_location_db(state, location_id, fn location_db ->
      Map.update!(location_db, :adjustments, fn adjustments ->
        adjustments
        |> Map.put_new(product_sku, [])
        |> Map.update!(product_sku, &[adjustment | &1])
      end)
    end)
  end

  defp add_product(state, location_id, product) do
    update_location_db(state, location_id, fn location_db ->
      Map.update!(location_db, :products, &Map.put(&1, product.sku, product))
    end)
  end

  defp get_adjustments_for_location(state, location_id) do
    state |> Map.get(location_id, %{}) |> Map.get(:adjustments, %{})
  end

  defp get_products_for_location(state, location_id) do
    state |> Map.get(location_id, %{}) |> Map.get(:products, %{})
  end

  defp update_location_db(state, location_id, callback) do
    state
    |> Map.put_new(location_id, %{products: %{}, adjustments: %{}})
    |> Map.update!(location_id, callback)
  end
end
