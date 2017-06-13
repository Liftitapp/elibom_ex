defmodule ElibomEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elibom_ex,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      name: "ElibomEx",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: preferred_cli_env(),
      source_url: "https://github.com/liftitapp/elibom_ex"
    ]
  end

  def application do
    [extra_applications: [:logger, :httpoison]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:poison, "~> 2.2"},
      {:httpoison, "~> 0.11"},
      {:exvcr, "~> 0.8", only: :test},
      {:dialyxir, "~> 0.4.1", only: :dev},
      {:credo, "~> 0.7.4", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    A wrapper for Elibom's API
    """
  end

  defp package do
    [
      name: :pubnux,
      maintainers: ["Jorge Madrid"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/liftitapp/elibom_ex"}
    ]
  end

  def preferred_cli_env do
    [
      vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
    ]
  end

  def aliases do
    [
      "ci": [
        "test",
        "credo"
      ]
    ]
  end
end
