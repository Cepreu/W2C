defmodule W2C.Mixfile do
  use Mix.Project

  def project do
    [app: :w2c,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :gproc, :cowboy, :plug, :poison, :mnesia],
      mod: {W2C.Application, []}
    ]
  end

  defp deps do
    [
      {:gproc, "0.3.1"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:meck, "0.8.2", only: :test},
      {:httpoison, "~> 0.9.0"},
      {:uuid, "~> 1.1"},
      {:poison, "~> 2.0"}
    ]
  end
end
