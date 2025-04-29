defmodule Temperature.MixProject do
  use Mix.Project

  def project do
    [
      app: :temperature,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Temperature.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:finch, "~> 0.17"},
      {:jason, "~> 1.0"},
      {:mime, "~> 2.0.6"},
      {:castore, "~> 1.0"},
      {:plug, "~> 1.14"}
    ]
  end

  defp aliases do
    []
  end
end
