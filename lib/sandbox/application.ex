defmodule Sandbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    load_jsons!()

    children = [
      # Start the Telemetry supervisor
      SandboxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Sandbox.PubSub},
      # Start the API Endpoint (http/https)
      {Plug.Cowboy, scheme: :http, plug: SandboxAPI.Endpoint, options: [port: 4000]},
      # Start the Web Endpoint (http/https)
      SandboxWeb.Endpoint
      # Start a worker by calling: Sandbox.Worker.start_link(arg)
      # {Sandbox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sandbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SandboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp load_jsons!() do
    account_names = load_json!("./data/account_names.json")
    institutions = load_json!("./data/institutions.json")
    merchants = load_json!("./data/merchants.json")
    merchant_categories = load_json!("./data/merchant_categories.json")
    descriptions = load_json!("./data/descriptions.json")

    Application.put_env(
      :sandbox,
      :mock_data,
      %{
        account_names: account_names,
        institutions: institutions,
        merchants: merchants,
        merchant_categories: merchant_categories,
        descriptions: descriptions
      },
      persistent: true
    )
  end

  defp load_json!(path) do
    path
    |> File.read!()
    |> Jason.decode!()
  end
end
