defmodule Sandbox.Models.Account do
  @moduledoc """
  Module that defines the Account struct and types.

  See https://teller.io/docs/api/2020-10-12#accounts_anchor
  """

  alias Sandbox.Models.{AccountDetails, Institution, Links}

  defstruct id: "",
            currency_code: "USD",
            enrollment_id: "",
            details: nil,
            institution: %{name: "", id: ""},
            last_four: "0000",
            links: nil,
            name: "",
            subtype: :checking,
            type: :depository

  @type url() :: String.t()
  @type id() :: String.t()
  @type account_number() :: String.t()
  @type currency_code() :: String.t()
  @type enrollment_id() :: String.t()
  @type subtype() :: :checking | :savings
  @type type() :: :depository
  @type last_four() :: String.t()
  @type t() :: %__MODULE__{
          id: id(),
          details: AccountDetails.t(),
          currency_code: currency_code(),
          enrollment_id: enrollment_id(),
          institution: Institution.t(),
          last_four: last_four(),
          links: nil | Links.account_links(),
          name: String.t(),
          subtype: subtype(),
          type: type()
        }

  defimpl Jason.Encoder do
    def encode(account, opts) do
      account
      |> Map.take([
        :id,
        :currency_code,
        :enrollment_id,
        :institution,
        :last_four,
        :links,
        :name,
        :subtype,
        :type
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
