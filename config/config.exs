# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sandbox,
  token_secret: "my token secret"

# Configures the API endpoint
config :sandbox, SandboxAPI.Endpoint, url: [host: "localhost"]

# Configures the endpoint
config :sandbox, SandboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "23rZMqbvpj743GbZwyqzBmwJP5ttAiixuEnLTFIWgrA67UTQz0pwcQrJ8f0Hr3QZ",
  render_errors: [view: SandboxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Sandbox.PubSub,
  live_view: [signing_salt: "SsKahdHY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
