defmodule Sqlcipher.Ecto.Mixfile do
  use Mix.Project

  def project do
    [app: :sqlcipher_ecto,
     version: "1.0.0",
     name: "Sqlcipher.Ecto",
     elixir: "~> 1.0",
     deps: deps,

     # testing
     build_per_environment: false,
     test_paths: test_paths(Mix.env),
     aliases: ["test.all": &test_all/1,
               "test.integration": &test_integration/1],
     preferred_cli_env: ["test.all": :test],

     # hex
     description: description,
     package: package,

     # docs
     docs: [main: Sqlcipher.Ecto]]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :ecto]]
  end

  # Dependencies
  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev},
     {:ecto, "~> 1.1"},
     {:poison, "~> 1.0"},
     {:sqlcx, "~> 1.0"}]
  end

  defp description, do: "SQLCipher adapter for Ecto"

  defp package do
    [maintainers: ["Felix Kiunke"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/FelixKiunke/sqlcipher_ecto"}]
  end

  defp test_paths(:integration), do: ["integration/sqlcipher"]
  defp test_paths(_), do: ["test"]

  defp test_integration(args) do
    args = if IO.ANSI.enabled?, do: ["--color" | args], else: ["--no-color" | args]
    System.cmd "mix", ["test" | args], into: IO.binstream(:stdio, :line),
                                       env: [{"MIX_ENV", "integration"}]
  end

  defp test_all(args) do
    Mix.Task.run "test", args
    {_, res} = test_integration(args)
    if res != 0, do: exit {:shutdown, 1}
  end
end
