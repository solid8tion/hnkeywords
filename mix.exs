defmodule Hnkeywords.MixProject do
  use Mix.Project

  def project do
    [
      app: :hnkeywords,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Hnkeywords.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"} ,
      {:exqlite, "0.13.2"},
      {:ecto_sql, "~> 3.9"},
      {:ecto_sqlite3, "~> 0.9.1"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:bamboo, "~> 2.3.0"},
      {:bamboo_ses, "~> 0.3.0"},
      {:hackney, "~> 1.9"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
