defmodule Sandbox.Util do
  @moduledoc """
  Utility module containing various PRNG seed state handling.
  Erlang :rand module is used, with the default :exsss (exsplus)
  algorithm.
  Unfortunatelly, :exsss uses improper lists which need special handling.
  """
  @dialyzer {:no_improper_lists, {:seed_multiply, 2}}

  @type rand_state() :: :rand.export_state()
  @type date() :: Sandbox.Models.Transaction.date()
  @type exsplus_state() :: {:exsss, nonempty_improper_list(number(), number())}

  @default_algorithm :exsss
  # @default_algorithm :exro928ss

  @spec get_state() :: rand_state()
  @doc """
    Generate a new seed state for the given random algorithm.
    More info can be found in the Erlang :rand module.
  """
  def get_state() do
    seed_state = :rand.seed(@default_algorithm)
    :rand.export_seed_s(seed_state)
  end

  @spec gen_id(rand_state(), String.t(), String.t()) :: {String.t(), rand_state()}
  @doc """
    Generate a random ID, that is base32 encoded with padding removed.
    - (string) prefix - The prefix for the generated ID.
    - (string) suffix - The suffix for the generated ID.
  """
  def gen_id(state, prefix \\ "", suffix \\ "") do
    {code, state} = gen_id_code(state)
    {"#{prefix}#{code}#{suffix}", state}
  end

  @spec gen_id_code(rand_state()) :: {String.t(), rand_state()}
  @doc """
  Generate a random ID that is base 32 encoded, in lowercase and
  with padding removed.
  """
  def gen_id_code(state) do
    {rnd, state} = get_random(state, 1_000_000_000_000_000, 9_000_000_000_000_000)
    code = Base.encode32(Integer.to_string(rnd), case: :lower, padding: false)
    {code, state}
  end

  @doc """
  Get a random item in a list, given state.

  The first argument must be a random state to use for generating randomness.

  The second argument is a list out of which to pick a random item.

  ## Return values

  Returns a tuple consisting of the random item as first element, and the new state as second element.
  """
  @spec get_random(state :: rand_state(), list :: list()) :: {nil | any(), rand_state()}
  def get_random(state, []) do
    {nil, state}
  end

  def get_random(state, [_ | _] = list) do
    max = Enum.count(list)
    {rnd, state} = get_random(state, 0, max - 1)
    {Enum.at(list, rnd), state}
  end

  @doc """
  Get a random number, given state.

  The first argument must be a random state to use for generating randomness.

  The second argument is the minimum number that can be returned.
  The third argument is the maximum number that can be returned.

  `precision` is the precision to use for the resulting number.
  If set to `0`, then the result will be an integer, otherwise a float
  with the given precision.


  ## Return values

  Returns a tuple consisting of the random number as first element, and the new state as second element.

  The random number returned is `min >= N <= max`
  """
  @spec get_random(
          state :: rand_state(),
          min :: number(),
          max :: number(),
          precision :: non_neg_integer()
        ) ::
          {number(), rand_state()}
  def get_random(state, min, max, precision \\ 0) do
    seed = :rand.seed(state)
    {rnd, seed} = :rand.uniform_s(seed)
    rnd = round((max - min) * rnd + min, precision)
    state = :rand.export_seed_s(seed)
    {rnd, state}
  end

  @spec round(float(), non_neg_integer()) :: number()
  def round(value, 0) do
    value
    |> Float.round(0)
    |> trunc()
  end

  def round(value, precision) do
    Float.round(value, precision)
  end

  @spec get_date_seed(rand_state(), date()) :: rand_state()
  def get_date_seed(seed, date) do
    n_date = date.year * 10000 + date.month * 100 + date.day

    seed_multiply(seed, n_date)
  end

  @spec seed_multiply(exsplus_state(), number()) :: exsplus_state()
  def seed_multiply({:exsss, [hi | lo]}, multiplier) do
    {:exsss, [hi * multiplier | lo * multiplier]}
  end

  # def seed_multiply({:exro928ss, {rnd_list, rnd_list_b}}, multiplier) do
  #   {:exro928ss,
  #    {Enum.map(rnd_list, &(&1 * multiplier)), Enum.map(rnd_list_b, &(&1 * multiplier))}}
  # end
end
