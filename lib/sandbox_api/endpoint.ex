defmodule SandboxAPI.Endpoint do
  use Plug.Router

  plug Plug.Logger

  plug :match

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Phoenix.json_library()
  )

  plug :dispatch

  plug SandboxAPI.Authorizer

  plug SandboxAPI.Router

  match _ do
    conn
  end
end
