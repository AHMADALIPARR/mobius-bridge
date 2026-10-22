defmodule Mobius.MixProject do
  use Mix.Project

  def project do
    [
      app: :mobius,
      version: "0.14.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Mobius.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:nimble_options, "~> 1.1"}
    ]
  end
end
