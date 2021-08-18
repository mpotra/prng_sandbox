defmodule Mix.Tasks.GenToken do
  use Mix.Task

  @requirements ["app.start"]

  @shortdoc "Generates a new Token"
  def run(_) do
    # Generate a new test token to be used in authorization header Basic username
    ("test_" <> Sandbox.Token.gen_new())
    |> IO.puts()
  end
end
