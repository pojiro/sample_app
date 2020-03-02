use Mix.Config

# Configure your database
config :sample_app, SampleApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "sample_app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sample_app, SampleAppWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# ease up the number of hashing rounds to speed up test
config :pbkdf2_elixir, :rounds, 1

config :sample_app, SampleAppWeb.Mailer, adapter: Bamboo.TestAdapter
