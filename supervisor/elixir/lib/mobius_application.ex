defmodule Mobius.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Mobius.Controller, [dim: 4]},
      {Mobius.TCPIngestion, [port: 14_014]},
      {Mobius.AuditLog, []}
    ]

    opts = [strategy: :one_for_one, name: Mobius.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
