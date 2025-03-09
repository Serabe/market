defmodule Market.Utils.MoneyTest do
  use ExUnit.Case

  alias Market.Utils.Money

  describe "times/2" do
    test "conserves currency" do
      assert Money.times({100, :usd}, 2) == {200, :usd}
      assert Money.times({100, :gbp}, 2) == {200, :gbp}
      assert Money.times({100, :yen}, 2) == {200, :yen}
    end
  end

  describe "sub/2" do
    test "can substract two amounts of the same currency" do
      assert Money.sub({100, :usd}, {25, :usd}) == {75, :usd}
    end

    test "can substract two amounts of different currencies" do
      assert Money.sub({100, :gbp}, {100, :usd}) == {27, :eur}
    end
  end

  describe "sum/2" do
    test "can sum two amounts of the same currency" do
      assert Money.sum({100, :usd}, {25, :usd}) == {125, :usd}
    end

    test "can sum two amounts of different currencies" do
      assert Money.sum({100, :usd}, {100, :gbp}) == {211, :eur}
    end
  end

  describe "format/1" do
    test "formats amounts with cents" do
      assert Money.format({100, :usd}) == "$1.00"
      assert Money.format({100, :gbp}) == "£1.00"
      assert Money.format({100, :yen}) == "¥100"
    end

    test "formats amount that are just cents" do
      assert Money.format({1, :usd}) == "$0.01"
      assert Money.format({1, :gbp}) == "£0.01"
      assert Money.format({1, :yen}) == "¥1"
      assert Money.format({10, :usd}) == "$0.10"
      assert Money.format({10, :gbp}) == "£0.10"
    end
  end
end
