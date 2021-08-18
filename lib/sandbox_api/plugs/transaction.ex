defmodule SandboxAPI.Plugs.Transaction do
  @moduledoc """
  Plug to handle accounts
  """

  @behaviour Plug

  import Plug.Conn

  alias SandboxAPI.Plugs.Transactions

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    transactions = conn.assigns[:transactions]

    case find_transaction_index(transactions, conn.params) do
      nil ->
        conn
        |> put_resp_header("content-type", "application/json; charset=utf-8")
        |> send_resp(404, Jason.encode!(%{error: "Not found"}))
        |> halt()

      index ->
        # Get the matching transaction and all previous by date transactions.
        [transaction | prev_transactions] = Enum.slice(transactions, index..-1)

        # Calculate the running balance of the transaction.

        # Note: Given the stateless generation of transactions, each one
        # already has the running balance computed.
        # But we're doing it here again, to show how we'd compute it
        # per individual transaction.
        transaction = set_running_balance(transaction, prev_transactions)

        assign(conn, :transaction, transaction)
    end
  end

  def set_running_balance(%{status: :posted} = transaction, []) do
    %{transaction | running_balance: 0}
  end

  def set_running_balance(%{status: :posted} = transaction, [_ | _] = prev_transactions) do
    running_balance = Transactions.calculate_running_balance(prev_transactions)
    %{transaction | running_balance: Float.round(running_balance, 2)}
  end

  def set_running_balance(%{status: :pending} = transaction, _) do
    %{transaction | running_balance: nil}
  end

  defp find_transaction_index([], _) do
    nil
  end

  defp find_transaction_index([_ | _] = transactions, %{
         "transaction_id" => "txn_" <> _ = transaction_id
       }) do
    Enum.find_index(transactions, &(&1.id == transaction_id))
  end

  defp find_transaction_index(_, _) do
    nil
  end
end
