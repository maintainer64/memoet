defmodule Memoet.MixProject do
  use Mix.Project

  def project do
    [
      app: :memoet,
      version: "0.1.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Memoet.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:db_connection, "~> 2.3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.17"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:ecto_psql_extras, "~> 0.2"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.6"},
      {:poison, "~> 4.0"},
      {:paginator, "~> 1.0.4"},
      {:cachex, "~> 3.3"},
      # Markdown
      {:earmark, "~> 1.4"},
      {:html_sanitize_ex, "~> 1.4"},
      # Sm2
      {:rustler, "~> 0.23.0"},
      # Auth
      {:pow, "~> 1.0"},
      {:pow_postgres_store, "~> 1.0"},
      # Cron
      {:oban, "~> 2.5"},
      # S3 upload
      {:waffle, "~> 1.1"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.1"},
      {:sweet_xml, "~> 0.6"},
      # Csv
      {:nimble_csv, "~> 1.1.0"},
      # Mailer
      {:swoosh, "~> 1.3"},
      {:hackney, "~> 1.16"},
      {:mail, "~> 0.2"},
      # Monitoring
      {:sentry, "~> 8.0"},
      # Icons
      {:heroicons, "~> 0.2"},
      # Lint & test
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_machina, "~> 2.7.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "assets.deploy": [
        "phx.digest"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
