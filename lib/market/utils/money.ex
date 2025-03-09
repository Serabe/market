defmodule Market.Utils.Money do
  @moduledoc """
  A simple way to manage {value, currency} as a Money pattern.
  """

  @doc """
  Times a money by an integer.
  """
  def times({value, currency}, times) when is_integer(times) do
    {value * times, currency}
  end

  def div({value, currency}, denominator) when denominator != 0 do
    {Kernel.div(value, denominator), currency}
  end

  @doc """
  Substract to moneys
  """
  def sub({value, currency}, {other_value, currency}) do
    {value - other_value, currency}
  end

  def sub(a, b) do
    sub(to_eur(a), to_eur(b))
  end

  @doc """
  Add two moneys.
  """
  def sum({value, currency}, {other_value, currency}) do
    {value + other_value, currency}
  end

  def sum(a, b) do
    sum(to_eur(a), to_eur(b))
  end

  def format({value, currency}) do
    case place_for_symbol?(currency) do
      :before ->
        "#{symbol(currency)}#{format_value(currency, value)}"

      :after ->
        "#{format_value(currency, value)}#{symbol(currency)}"
    end
  end

  defp format_value(currency, value) do
    as_string = Integer.to_string(value)

    if has_cents?(currency) do
      {integer, decimal} = as_string |> String.pad_leading(3, "0") |> String.split_at(-2)
      "#{integer}.#{decimal}"
    else
      as_string
    end
  end

  defp has_cents?(:yen), do: false
  defp has_cents?(_currency), do: true

  defp place_for_symbol?(:eur), do: :after
  defp place_for_symbol?(:usd), do: :before
  defp place_for_symbol?(:gbp), do: :before
  defp place_for_symbol?(:yen), do: :before
  defp place_for_symbol?(_other), do: :after

  defp symbol(:eur), do: "€"
  defp symbol(:usd), do: "$"
  defp symbol(:gbp), do: "£"
  defp symbol(:yen), do: "¥"
  defp symbol(_other), do: "$"

  defp to_eur({value, currency}) do
    {conversion_rate(currency) * value, :eur}
  end

  defp conversion_rate(:usd), do: 0.92
  defp conversion_rate(:gbp), do: 1.19
  defp conversion_rate(:yen), do: 0.0062
  # Easier for testing and this is just a toy
  defp conversion_rate(_other), do: 1
end
