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

  #### GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
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

  def handle_call({:get_products, location_id, skus}, _from, state) do
    location_db = Map.get(state, location_id, %{})

    products =
      skus |> List.wrap() |> Enum.map(&Map.get(location_db, &1, nil)) |> Enum.reject(&is_nil/1)

    {:reply, products, state}
  end
end
