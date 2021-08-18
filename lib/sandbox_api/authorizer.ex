defmodule SandboxAPI.Authorizer do
  @moduledoc """
  Plug to authorize the token and build the seeds
  """

  @behaviour Plug

  import Plug.Conn

  alias Sandbox.Token

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _) do
    case authorize(conn) do
      {:ok, token} ->
        assign(conn, :token, token)

      error ->
        send_error(conn, error)
    end
  end

  defp authorize(%Plug.Conn{} = conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> authorize()
  end

  defp authorize("Basic " <> authorization) do
    case Base.decode64(authorization) do
      {:ok, token} -> Token.parse(String.split(token, ":", parts: 2))
      _ -> {:error, :unauthorized}
    end
  end

  defp authorize(_) do
    {:error, :unauthorized}
  end

  defp send_error(conn, {:error, :invalid_token}) do
    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(401, Jason.encode!(%{error: "Invalid token"}))
    |> halt()
  end

  defp send_error(conn, {:error, :unauthorized}) do
    conn
    |> put_resp_header("www-authenticate", "Basic realm=\"Sandbox API\"")
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
    |> halt()
  end
end
