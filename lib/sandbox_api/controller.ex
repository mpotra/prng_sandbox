defmodule SandboxAPI.Controller do
  use Phoenix.Controller, namespace: SandboxAPI

  import Plug.Conn
  alias Sandbox.Models.{AccountBalances, Links}
  # alias SandboxAPI.Router.Helpers, as: Routes

  def list(conn, _params) do
    host = conn.assigns[:links_host]

    accounts =
      conn.assigns[:accounts]
      |> Enum.map(fn account ->
        %{account | links: Links.generate_links(host, account)}
      end)

    json(conn, accounts)
  end

  def account(conn, _params) do
    host = conn.assigns[:links_host]
    account = conn.assigns[:account]

    json(conn, %{account | links: Links.generate_links(host, account)})
  end

  def details(conn, _params) do
    host = conn.assigns[:links_host]
    details = conn.assigns[:account].details
    details = %{details | links: Links.generate_links(host, details)}
    json(conn, details)
  end

  def balances(conn, _params) do
    host = conn.assigns[:links_host]
    %{id: account_id} = conn.assigns[:account]

    # Calculate the ledger by adding up amounts in
    # all account transactions available.
    # O(n)
    ledger =
      conn.assigns[:transactions]
      |> Enum.reduce(0, fn %{amount: amount}, acc -> acc + amount end)

    balances = %AccountBalances{
      account_id: account_id,
      available: 0,
      ledger: Float.round(ledger, 2),
      links: nil
    }

    balances = %{balances | links: Links.generate_links(host, balances)}

    json(conn, balances)
  end

  @spec transactions(Plug.Conn.t(), %{
          optional(:count) => String.t(),
          optional(:from_id) => String.t()
        }) :: Plug.Conn.t()
  def transactions(conn, %{"from_id" => ""} = params) do
    transactions(conn, Map.delete(params, "from_id"))
  end

  def transactions(conn, %{"from_id" => from_id} = params) do
    transactions = conn.assigns[:transactions]

    case Enum.find_index(transactions, &(&1.id == from_id)) do
      nil ->
        error(conn, 404, "Transaction not found in from_id parameter")

      index ->
        conn
        |> assign(:transactions, Enum.slice(transactions, (index + 1)..-1))
        |> transactions(Map.delete(params, "from_id"))
    end
  end

  def transactions(conn, %{"count" => ""} = params) do
    transactions(conn, Map.delete(params, "count"))
  end

  def transactions(conn, %{"count" => count} = params) do
    case Integer.parse(count, 10) do
      {0, _} ->
        json(conn, [])

      {int_count, ""} ->
        transactions = conn.assigns[:transactions]

        conn
        |> assign(:transactions, Enum.slice(transactions, 0..(int_count - 1)))
        |> transactions(Map.delete(params, "count"))

      _ ->
        error(conn, 400, "Bad request. Invalid count parameter. Must be a positive integer")
    end
  end

  def transactions(conn, _params) do
    host = conn.assigns[:links_host]

    transactions =
      conn.assigns[:transactions]
      |> Enum.map(fn transaction ->
        %{transaction | links: Links.generate_links(host, transaction)}
      end)

    json(conn, transactions)
  end

  def transaction(conn, _params) do
    host = conn.assigns[:links_host]
    transaction = conn.assigns[:transaction]

    json(conn, %{transaction | links: Links.generate_links(host, transaction)})
  end

  defp error(conn, status_code, error) do
    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status_code, Jason.encode!(%{error: error}))
    |> halt()
  end
end
