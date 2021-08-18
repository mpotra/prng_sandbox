defmodule Sandbox.Models.TransactionDetails do
  @moduledoc """
  Module that defines the Transaction details struct and types.

  See `details` object in
  https://teller.io/docs/api/2020-10-12#transactions_anchor
  """

  defstruct category: "",
            counterparty: %{},
            processing_status: :pending

  @type counterparty_type() :: :person | :merchant | :organization
  @type processing_status() :: :complete | :pending

  @type t() :: %__MODULE__{
          category: String.t(),
          counterparty: %{
            name: String.t(),
            type: counterparty_type()
          },
          processing_status: processing_status()
        }

  defimpl Jason.Encoder do
    def encode(details, opts) do
      details
      |> Map.take([
        :category,
        :counterparty,
        :processing_status
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
