defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  @version "2.0.0"
  @source_url "https://github.com/FindHotel/analytics-elixir"

  def project do
    [
      app: :segment,
      deps: deps(),
      description: "analytics_elixir",
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "analytics_elixir",
      package: package(),
      version: @version
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:meta_logger, "~> 1.4"},
      {:miss, "~> 0.1"},
      {:poison, "~> 5.0"},
      {:tesla, "~> 1.5"},
      {:typed_struct, "~> 0.2", runtime: false},
      {:uuid, "~> 1.1"},

      # Dev
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},

      # Static analysis
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_environment), do: ["lib"]

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: [
        "Antonio Lorusso",
        "Felipe Vieira",
        "Fernando Hamasaki de Amorim",
        "Sergio Rodrigues"
      ]
    ]
  end
end
