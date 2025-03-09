defmodule Market.Store do
  @moduledoc """
  The Store module is responsible for managing the state of a store.

  A store would be a mix of a DB and a location in our chain of supermarkets.
  """

  use GenServer

  alias Market.Store.Product

  ### Client API

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
    london =
      %{}
      |> Map.put("GR1", Product.new(sku: "GR1", name: "Green tea", prices: %{1 => {311, :gbp}}))
      |> Map.put(
        "SR1",
        Product.new(
          sku: "SR1",
          name: "Strawberries",
          prices: %{(1..2) => {500, :gbp}, 3 => {450, :gbp}}
        )
      )
      |> Map.put("CF1", Product.new(sku: "CF1", name: "Coffee", prices: %{1 => {1123, :gbp}}))

    {:ok, %{"LDN" => london}}
  end

  def handle_cast({:add_product, location_id, %Product{} = product}, state) do
    state =
      state
      |> Map.put_new(location_id, %{})
      |> Map.update!(location_id, fn location_db ->
        Map.put(location_db, product.sku, product)
      end)

    {:noreply, state}
  end

  def handle_call({:exist_product, location_id, product_sku}, _from, state) do
    location_db = Map.get(state, location_id, %{})
    {:reply, Map.has_key?(location_db, product_sku), state}
  end

  def handle_call({:get_products, location_id, skus}, _from, state) do
    location_db = Map.get(state, location_id, %{})

    products =
      skus |> List.wrap() |> Enum.map(&Map.get(location_db, &1, nil)) |> Enum.reject(&is_nil/1)

    {:reply, products, state}
  end

  def handle_call({:get_snapshot, location_id, list_of_skus_and_quantities}, _from, state) do
    location_db = Map.get(state, location_id, %{})

    snapshot =
      Enum.map(list_of_skus_and_quantities, fn {sku, quantity} ->
        case Map.get(location_db, sku) do
          nil ->
            {sku, quantity, nil}

          product ->
            price = Product.unit_price_for_quantity(product, quantity)
            {sku, quantity, price}
        end
      end)

    {:reply, snapshot, state}
  end
end
