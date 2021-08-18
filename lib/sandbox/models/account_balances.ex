defmodule Sandbox.Models.AccountBalances do
  @moduledoc """
  Module that defines the Account Balances struct and types.

  See https://teller.io/docs/api/2020-10-12#account_balances_anchor
  """

  alias Sandbox.Models.{Account, Links}

  defstruct account_id: "",
            ledger: 0,
            available: 0,
            links: nil

  @type t() :: %__MODULE__{
          account_id: Account.id(),
          ledger: number(),
          available: number(),
          links: nil | Links.balances_links()
        }

  defimpl Jason.Encoder do
    def encode(details, opts) do
      details
      |> Map.take([
        :account_id,
        :ledger,
        :available,
        :links
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
