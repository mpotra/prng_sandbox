defmodule Sandbox.Models.Institution do
  @moduledoc """
  Module that defines the Institution struct and types.
  See https://teller.io/docs/api/2020-10-12#account_details_anchor
  """

  defstruct name: "",
            id: ""

  @type t() :: %{
          name: String.t(),
          id: String.t()
        }

  @spec get_id(String.t()) :: String.t()
  def get_id(name) do
    # Macro.underscore/1 doesn't treat non-word chars well
    Recase.to_snake(name)
  end
end
