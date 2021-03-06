# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sample_app,
  ecto_repos: [SampleApp.Repo]

# Configures the endpoint
config :sample_app, SampleAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3ALfZelIWQxVJuWpqcqOKBKMQI2ffQntyQmAHdUsxKul7zAvExnbxuOlQ8o5tCOB",
  render_errors: [view: SampleAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SampleApp.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "PCnJXTBi"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :scrivener_html,
  routes_helper: SampleAppWeb.Router.Helpers

config :git_hooks,
  verbose: true,
  hooks: [
    pre_commit: [
      tasks: [
        "mix format"
      ]
    ],
    pre_push: [
      tasks: []
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
