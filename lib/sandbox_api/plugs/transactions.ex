defmodule SandboxAPI.Plugs.Transactions do
  @moduledoc """
  Plug to handle transaction
  """

  @behaviour Plug

  import Plug.Conn

  alias Sandbox.Random

  @max_days_transactions 90

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _) do
    rnd_state = conn.assigns[:rnd_state]
    %{id: account_id} = conn.assigns[:account]
    date = Date.utc_today()

    {transactions, rnd_state} =
      Random.gen_random_transactions(rnd_state, account_id, date, @max_days_transactions)

    # Since we've generated the entire history of transactions above
    # and that won't change given the stateless nature of the API,
    # we might just as well calculate the running balance for each
    # in this step.
    # We're using a Enum.map_reduce/3 on the reversed list,
    # which is O(n) instead of invoking calculate_running_balance/1
    # for each item that would result in O(n^2) for all
    # our transactions.
    transactions =
      transactions
      |> Enum.reverse()
      |> Enum.map_reduce(0.00, fn %{amount: amount, status: status} = transaction,
                                  running_balance ->
        case status do
          :posted ->
            {Map.put(transaction, :running_balance, Float.round(running_balance, 2)),
             running_balance + amount}

          :pending ->
            {transaction, running_balance}
        end
      end)
      |> elem(0)
      |> Enum.reverse()

    conn
    |> assign(:rnd_state, rnd_state)
    |> assign(:transactions, transactions)
  end

  @doc """
  Calculates the running balance out of a list of transactions.
  """
  def calculate_running_balance([]) do
    0
  end

  def calculate_running_balance([%{amount: amount, status: :posted} | transactions]) do
    amount + calculate_running_balance(transactions)
  end

  def calculate_running_balance([_ | transactions]) do
    calculate_running_balance(transactions)
  end
end
