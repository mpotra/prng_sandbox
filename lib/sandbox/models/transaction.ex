defmodule Sandbox.Models.Transaction do
  @moduledoc """
  Module that defines the Transaction struct and types.

  See https://teller.io/docs/api/2020-10-12#transactions_anchor
  """

  alias Sandbox.Models.{Account, Links, TransactionDetails}

  defstruct account_id: "",
            amount: 0,
            date: nil,
            description: "",
            details: %TransactionDetails{},
            status: :pending,
            running_balance: nil,
            id: "",
            links: nil,
            type: :card_payment

  @type id() :: String.t()
  @type date() :: Date.t()
  @type status() :: :pending | :posted

  @type type() :: :ach | :transaction | :card_payment

  @type t() :: %__MODULE__{
          id: id(),
          account_id: Account.t(),
          amount: number(),
          date: date(),
          description: String.t(),
          details: TransactionDetails.t(),
          running_balance: nil | number(),
          status: status(),
          links: nil | Links.transaction_links(),
          type: type()
        }

  defimpl Jason.Encoder do
    def encode(transaction, opts) do
      transaction
      |> Map.take([
        :id,
        :date,
        :amount,
        :account_id,
        :description,
        :details,
        :running_balance,
        :status,
        :links,
        :type
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
