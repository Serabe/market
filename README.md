# Market

![CI](https://github.com/Serabe/market/actions/workflows/elixir-ci.yml/badge.svg)
![Dialyzer](https://github.com/Serabe/market/actions/workflows/dialyzer.yml/badge.svg)


## Installation

Download the project using git:

```bash
git clone https://github.com/Serabe/market.git
# or clone your fork
```

Get the dependencies. For this project, there are only dev and test dependencies:

- [Credo](https://hexdocs.pm/credo/overview.html), a kind of linter for Elixir.
- [Dialyxir](https://hexdocs.pm/dialyxir/readme.html), some mix tasks to use Dialyzer in Elixir projects.
- [mix test.interactive](https://hexdocs.pm/mix_test_interactive/readme.html), an interactive test runner for ExUnit,
  just because I don't know why something like this is not built in.

```bash
mix deps.get
```

Once the dependencies are installed, you can run the test with `mix test` (note that using `mix test.interactive` would re-run your tests whenever you change one of your files).
You can also run `iex` inside the project with
`iex -S mix`. There is a helper function, `print_price/1` exposed to IEx. It does not handles errors, but it just handles
inputs like the ones in the document.

```bash
iex(1)> print_price("GR1,SR1,GR1,GR1,CF1")
£22.45
:ok
iex(2)> print_price("GR1,GR1")
£3.11
:ok
iex(3)> print_price("SR1,SR1,GR1,SR1")
£16.61
:ok
iex(4)> print_price("GR1,CF1,SR1,CF1,CF1")
£30.57
:ok
```

The test data in the document can be found in the [market_test.exs](https://github.com/Serabe/market/blob/main/test/market_test.exs) file.

## About the code

It was requested to over engineered the solution. This was approached in several ways.

### Waterfall model (Peter DeGrace's sashimi model)

The project was approached as a modified waterfall model. While coding and testing would still be using TDD, as per the requirements,
the design would be done in a previous phase. In that phase, it would be decided that there would be two subprojects:

1. Base e-commerce with bulking prices. That would support the pricing requirements for strawberries. This would include structs for
   products, prices, cart, and line items. Also it would represent money in a loss-less fashion. Given using a DB is not a requirement,
   a GenServer called Store, where the information for products and adjustments would be store.
2. Second subproject would add basic adjustments to the store.

### Store and carts

Information about product prices and name are only store in the Store. References to products are only done through their Stock Keeping
Unit (SKU). Then we keep a snapshopt of current prices of each line item. This way we can notify in the future changes in prices, lack
of stock, etc. Preparing for features not in the road: more over-engineering.

### Products and prices

Prices in products are a map from "ranges" to prices. That way, bulk pricing can be easily be implemented.

### Money

Money is represented as a tuple `{value, currency}`. [`Market.Utils.Money`](https://github.com/Serabe/market/blob/main/lib/market/utils/money.ex)
contains some functions for operating with money, formatting it, converting currencies...
The pattern is similar to the Money pattern in other languages.

### Snapshot

Whenever anything changes in a cart, the snapshot changes. The snapshot contains the same information as the line
items (the source of truth) plus the current information of the prices plus any adjustments.

Think of line items as the what the user do to the cart (adding and removing items), and the snapshot as the
calculations resulting of it.

### Adjustments, conditions and calculators

And adjustment is represented by a condition and a calculator. And adjustment takes a snapshot line, checks its
condition and, if it passes, then calculates the adjustment line using its calculator.

You might be wondering why using atoms and values for representing functions when Elixir do this just fine. Well,
not all languages represent function as well as Elixir, and even when in Elixir, functions are not serializable
if we are in some frameworks. Even more, if we were to store this data in a DB, with this approach, it would not
be easily possible if we were using functions.