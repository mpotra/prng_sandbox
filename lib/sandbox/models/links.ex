defmodule Sandbox.Models.Links do
  alias Sandbox.Models.{Account, AccountBalances, AccountDetails, Transaction}

  @type host() :: String.t()
  @type url() :: String.t()
  @type account_links() :: %{
          required(:balances) => url(),
          required(:transactions) => url(),
          required(:account) => url(),
          required(:self) => url()
        }
  @type transaction_links() :: %{
          required(:account) => url(),
          required(:self) => url()
        }
  @type details_links() :: %{
          required(:account) => url(),
          required(:self) => url()
        }
  @type balances_links() :: %{
          required(:account) => url(),
          required(:self) => url()
        }

  @spec generate_links(
          host(),
          Account.t()
        ) ::
          account_links()
  def generate_links(host, %Account{id: account_id}) do
    %{
      self: generate_account_link(host, account_id),
      balances: generate_balances_link(host, account_id),
      details: generate_details_link(host, account_id),
      transactions: generate_transactions_link(host, account_id)
    }
  end

  @spec generate_links(host(), AccountBalances.t()) :: balances_links()
  def generate_links(host, %AccountBalances{account_id: account_id}) do
    %{
      account: generate_account_link(host, account_id),
      self: generate_balances_link(host, account_id)
    }
  end

  @spec generate_links(host(), AccountDetails.t()) :: details_links()
  def generate_links(host, %AccountDetails{account_id: account_id}) do
    %{
      account: generate_account_link(host, account_id),
      self: generate_details_link(host, account_id)
    }
  end

  @spec generate_links(host(), Transaction.t()) :: transaction_links()
  def generate_links(host, %Transaction{id: transaction_id, account_id: account_id}) do
    %{
      account: generate_account_link(host, account_id),
      self: generate_transaction_link(host, account_id, transaction_id)
    }
  end

  @spec generate_link(
          host(),
          Account.t() | AccountDetails.t() | AccountBalances.t() | Transaction.t()
        ) :: url()
  def generate_link(host, %Account{id: account_id}) do
    generate_account_link(host, account_id)
  end

  def generate_link(host, %AccountBalances{account_id: account_id}) do
    generate_balances_link(host, account_id)
  end

  def generate_link(host, %AccountDetails{account_id: account_id}) do
    generate_details_link(host, account_id)
  end

  def generate_link(host, %Transaction{id: transaction_id, account_id: account_id}) do
    generate_transaction_link(host, account_id, transaction_id)
  end

  @spec generate_account_link(host(), Account.id()) :: url()
  def generate_account_link(host, account_id) do
    "#{host}/accounts/#{account_id}"
  end

  @spec generate_balances_link(host(), Account.id()) :: url()
  def generate_balances_link(host, account_id) do
    "#{generate_account_link(host, account_id)}/balances"
  end

  @spec generate_details_link(host(), Account.id()) :: url()
  def generate_details_link(host, account_id) do
    "#{generate_account_link(host, account_id)}/details"
  end

  @spec generate_transactions_link(host(), Account.id()) :: url()
  def generate_transactions_link(host, account_id) do
    "#{generate_account_link(host, account_id)}/transactions"
  end

  @spec generate_transaction_link(host(), Account.id(), Transaction.id()) :: url()
  def generate_transaction_link(host, account_id, transaction_id) do
    "#{generate_transactions_link(host, account_id)}/#{transaction_id}"
  end
end
