defmodule Recurrencex.MixProject do
  use Mix.Project

  def project do
    [
      app: :recurrencex,
      version: "0.2.0",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      test: test()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :timex
      ]
    ]
  end

  defp deps do
    [
      {:timex, "~>3.2"},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Recurrencex is a simple date recurrence library for elixir projects, supporting
    daily, weekly, monthly day, and monthly relative day of week recurrences.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Ben Hu"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/Ben-Hu/recurrencex"}
    ]
  end

  defp docs do
    [
      main: "Recurrencex",
      name: "Recurrencex",
      source_url: "https://github.com/Ben-Hu/recurrencex",
      homepage_url: "https://github.com/Ben-Hu/recurrencex",
      extras: ["README.md"]
    ]
  end

  defp test do
    [
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end
end
