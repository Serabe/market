defmodule Market.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    children =
      if Keyword.get(args, :env, :prod) == :test do
        []
      else
        [
          # Starts a worker by calling: Market.Worker.start_link(arg)
          {Market.Store, []}
        ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Market.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
