defmodule Rainbow.MixProject do
  use Mix.Project

  def project do
    [
      app: :rainbow,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:typed_struct, "~> 0.1.4", runtime: false},
      {:sweet_xml, "~> 0.6.6"}
    ]
  end
end
