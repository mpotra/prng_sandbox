defmodule Sandbox.Models.AccountDetails do
  @moduledoc """
  Module that defines the Account Details struct and types.

  See https://teller.io/docs/api/2020-10-12#account_details_anchor
  """

  alias Sandbox.Models.{Account, Links}

  defstruct account_id: "",
            account_number: 0,
            links: nil,
            routing_numbers: %{}

  @type routing_number(key) :: %{required(key) => String.t()}
  @type routing_numbers() :: routing_number(:ach) | routing_number(:wire) | routing_number(:bacs)

  @type t() :: %__MODULE__{
          account_id: Account.id(),
          account_number: Account.account_number(),
          links: nil | Links.details_links(),
          routing_numbers: routing_numbers()
        }

  defimpl Jason.Encoder do
    def encode(details, opts) do
      details
      |> Map.take([
        :account_id,
        :account_number,
        :links,
        :routing_numbers
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
