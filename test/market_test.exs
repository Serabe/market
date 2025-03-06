defmodule MarketTest do
  use ExUnit.Case
  doctest Market

  test "greets the world" do
    assert Market.hello() == :world
  end
end
