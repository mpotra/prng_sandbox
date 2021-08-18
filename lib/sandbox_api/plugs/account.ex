defmodule SandboxAPI.Plugs.Account do
  @moduledoc """
  Plug to handle accounts
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    case find_account(conn.assigns[:accounts], conn.params) do
      nil ->
        conn
        |> put_resp_header("content-type", "application/json; charset=utf-8")
        |> send_resp(404, Jason.encode!(%{error: "Not found"}))
        |> halt()

      account ->
        assign(conn, :account, account)
    end
  end

  defp find_account([], _) do
    nil
  end

  defp find_account([_ | _] = accounts, %{"account_id" => "acc_" <> _ = account_id}) do
    accounts
    |> Enum.find(fn
      %{id: ^account_id} = account -> account
      _ -> nil
    end)
  end

  defp find_account(_, _) do
    nil
  end
end
