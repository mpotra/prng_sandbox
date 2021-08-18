defmodule Sandbox.Token do
  @moduledoc """
  The module that handles Token encoding/decoding.

  A token always contains a `:state` key which holds
  the rand state to use in generating random data.
  """
  defstruct state: nil

  @type t() :: %__MODULE__{
          state: {:exsss, maybe_improper_list(number(), number())}
        }

  @spec gen_new() :: binary()
  def gen_new() do
    %__MODULE__{
      state: Sandbox.Util.get_state()
    }
    |> encrypt()
  end

  @spec parse(list(String.t())) :: {:error, :invalid_token} | {:ok, struct}
  def parse(["test_" <> token, _]) do
    token_secret = Application.fetch_env!(:sandbox, :token_secret)
    decrypt(token, token_secret)
  end

  def parse(_) do
    {:error, :invalid_token}
  end

  def encrypt(data) do
    encrypt(data, Application.fetch_env!(:sandbox, :token_secret))
  end

  @spec encrypt(map(), String.t()) :: String.t()
  def encrypt(data, secret) when is_map(data) do
    Jason.encode!(data)
    |> encrypt(secret)
  end

  @spec encrypt(String.t(), String.t()) :: String.t()
  def encrypt(data, secret) when is_binary(data) do
    _secret(secret)
    |> JOSE.JWE.block_encrypt(data, %{"alg" => "PBES2-HS256+A128KW", "enc" => "A128GCM"})
    |> JOSE.JWE.compact()
    |> elem(1)
    |> Base.encode64()
  end

  @spec decrypt(String.t()) :: {:error, :invalid_token} | {:ok, t()}
  def decrypt(hash) do
    decrypt(hash, Application.fetch_env!(:sandbox, :token_secret))
  end

  @spec decrypt(String.t(), String.t()) :: {:error, :invalid_token} | {:ok, t()}
  def decrypt(hash, secret) do
    with {:ok, hash} <- Base.decode64(hash) do
      try do
        JOSE.JWE.block_decrypt(_secret(secret), hash)
        |> elem(0)
        |> Jason.decode!()
        |> decode_state!()
      rescue
        _ ->
          {:error, :invalid_token}
      else
        data -> {:ok, struct!(__MODULE__, data)}
      end
    else
      _ -> {:error, :invalid_token}
    end
  end

  defp _secret(data) do
    JOSE.JWK.from_oct(data)
  end

  defp decode_state!(%{"state" => %{"alg" => "exsss", "list" => [a, b]}} = token) do
    token
    |> Map.delete("state")
    |> Map.put(:state, {:exsss, [a | b]})
  end

  defp decode_state!(_) do
    raise "Invalid token state"
  end

  defimpl Jason.Encoder do
    def encode(token, opts) do
      token
      |> Map.take([])
      |> Map.put(:state, encode_state(token.state))
      |> Jason.Encode.map(opts)
    end

    defp encode_state({:exsss, [a | b]}) do
      %{
        alg: :exsss,
        list: [a, b]
      }
    end
  end
end
