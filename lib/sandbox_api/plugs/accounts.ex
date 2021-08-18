defmodule SandboxAPI.Plugs.Accounts do
  @moduledoc """
  Plug to handle transaction
  """

  @behaviour Plug

  import Plug.Conn

  alias Sandbox.Random

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _) do
    rnd_state = conn.assigns[:token].state

    {accounts, rnd_state} = Random.gen_random_accounts(rnd_state)

    conn
    |> assign(:links_host, get_host(conn))
    |> assign(:rnd_state, rnd_state)
    |> assign(:accounts, accounts)
  end

  defp get_host(conn) do
    IO.iodata_to_binary([
      to_string(conn.scheme),
      "://",
      conn.host,
      request_url_port(conn.scheme, conn.port)
    ])
  end

  defp request_url_port(:http, 80), do: ""
  defp request_url_port(:https, 443), do: ""
  defp request_url_port(_, port), do: [?:, Integer.to_string(port)]
end
