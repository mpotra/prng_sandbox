defmodule Sandbox.Random do
  alias Sandbox.Models.{
    Account,
    AccountDetails,
    Institution,
    Transaction,
    TransactionDetails
  }

  alias Sandbox.Util

  @type rand_state() :: Util.rand_state()

  def gen_random_accounts(rnd_state) do
    {num_accounts, rnd_state} = Util.get_random(rnd_state, 1, 5)

    Enum.reduce(0..num_accounts, {[], rnd_state}, fn _, {accounts, rnd_state} ->
      {account, rnd_state} = gen_random_account(rnd_state)
      {[account | accounts], rnd_state}
    end)
  end

  def gen_random_account(state) do
    {account_id, state} = Util.gen_id(state, "acc_")

    {name, state} = gen_random_account_name(state)
    {account_details, state} = gen_random_account_details(state, account_id)
    {institution, state} = gen_random_institution(state)
    {enrollment_id, state} = Util.gen_id(state, "enr_")
    {last_four, state} = gen_random_account_last_four(state)

    account = %Account{
      id: account_id,
      details: account_details,
      currency_code: "USD",
      enrollment_id: enrollment_id,
      institution: institution,
      last_four: last_four,
      name: name
    }

    {account, state}
  end

  def gen_random_account_details(state, account_id) do
    {account_number, state} = Util.get_random(state, 300_000_000_000, 900_000_000_000)
    {routing_number, state} = Util.get_random(state, 100_000_000, 999_999_999)

    details = %AccountDetails{
      account_id: account_id,
      account_number: account_number,
      routing_numbers: %{ach: routing_number}
    }

    {details, state}
  end

  def gen_random_account_name(state) do
    mock_data = Application.fetch_env!(:sandbox, :mock_data)
    Util.get_random(state, mock_data.account_names)
  end

  def gen_random_institution(state) do
    mock_data = Application.fetch_env!(:sandbox, :mock_data)
    {name, state} = Util.get_random(state, mock_data.institutions)

    institution = %{
      name: name,
      id: Institution.get_id(name)
    }

    {institution, state}
  end

  def gen_random_account_last_four(state) do
    Util.get_random(state, 1000, 9999)
  end

  @doc """
  Transactions are generated per day, so they need
  a date-based seed.

  E.g. base seed *  "YYYYMMDDYYYYMMDD` integer

  Base seed is used for randomness within the token scope,
  while date multiplication gives uniqueness per date.
  Different base seeds multiplied by date => different randoms.

  """
  def gen_random_transactions(state, _account_id, _start_date, 0) do
    {[], state}
  end

  def gen_random_transactions(base_state, account_id, start_date, days) do
    state = Util.get_date_seed(base_state, start_date)
    {date_transactions, _state} = gen_random_date_transactions(state, account_id, start_date)

    {transactions, _state} =
      gen_random_transactions(base_state, account_id, Date.add(start_date, -1), days - 1)

    {Enum.concat(date_transactions, transactions), base_state}
  end

  @doc """
  Generate a random number of transactions, between 0 and 5.
  """
  @spec gen_random_date_transactions(rand_state(), Account.id(), Transaction.date()) ::
          {list(Transaction.t()), rand_state()}
  def gen_random_date_transactions(state, account_id, date) do
    {num, state} = Util.get_random(state, 0, 5)
    gen_random_date_transactions(state, account_id, date, num)
  end

  def gen_random_date_transactions(state, _account_id, _date, 0) do
    {[], state}
  end

  def gen_random_date_transactions(state, account_id, date, num) do
    {transaction, state} = gen_random_transaction(state, account_id, date)
    {transactions, state} = gen_random_date_transactions(state, account_id, date, num - 1)
    {[transaction | transactions], state}
  end

  def gen_random_transaction(state, account_id, date) do
    {transaction_id, state} = Util.gen_id(state, "txn_")

    {amount, state} = gen_random_tx_amount(state)
    {category, state} = gen_random_tx_category(state)
    {counterparty_name, state} = gen_random_tx_counterparty_name(state)
    {description, state} = gen_random_tx_description(state)
    {status, state} = gen_random_tx_status(state)

    transaction = %Transaction{
      id: transaction_id,
      account_id: account_id,
      amount: amount,
      date: date,
      description: description,
      details: %TransactionDetails{
        category: category,
        counterparty: %{
          name: counterparty_name,
          type: :organization
        },
        processing_status: :complete
      },
      status: status,
      type: :card_payment
    }

    {transaction, state}
  end

  def gen_random_tx_amount(state) do
    Util.get_random(state, -10, -9999, 2)
  end

  def gen_random_tx_category(state) do
    mock_data = Application.fetch_env!(:sandbox, :mock_data)
    Util.get_random(state, mock_data.merchant_categories)
  end

  def gen_random_tx_counterparty_name(state) do
    mock_data = Application.fetch_env!(:sandbox, :mock_data)
    Util.get_random(state, mock_data.merchants)
  end

  def gen_random_tx_description(state) do
    mock_data = Application.fetch_env!(:sandbox, :mock_data)

    Util.get_random(state, mock_data.descriptions)
  end

  @doc """
  Generates a random transaction status.
  In this implementation, the ratio is 3:1 for posted:pending
  in order to decrease chances of pending transactions.
  """
  def gen_random_tx_status(state) do
    Util.get_random(state, [:posted, :posted, :posted, :pending])
  end
end
