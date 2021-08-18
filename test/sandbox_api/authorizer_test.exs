defmodule SandboxAPI.AuthorizerTest do
  use SandboxAPI.ConnCase, async: true
  alias Sandbox.Token

  describe "Requests" do
    test "return 401 Unauthorized with missing Authorization header" do
      build_conn()
      |> get("/accounts")
      |> json_response(401)
    end

    test "return 401 Unauthorized with empty username" do
      build_conn()
      |> with_basic_auth("")
      |> get("/accounts")
      |> json_response(401)
    end

    test "return 401 Unauthorized with test_ username" do
      build_conn()
      |> with_basic_auth("test_")
      |> get("/accounts")
      |> json_response(401)
    end

    test "return 200 with Token.new() + Token.encrypt()" do
      token = Token.new()
      user = "test_" <> Token.encrypt(token)

      build_conn()
      |> with_basic_auth(user)
      |> get("/accounts")
      |> json_response(200)
    end

    test "return 200 with Token.gen_new()" do
      user = "test_" <> Token.gen_new()

      build_conn()
      |> with_basic_auth(user)
      |> get("/accounts")
      |> json_response(200)
    end
  end

  describe "Invalid token requests" do
    test "return 401 Unauthorized with wrong salt encrypted token" do
      token = Token.new()

      secret = Application.fetch_env!(:sandbox, :token_secret) <> "-altered"
      user = "test_" <> Token.encrypt(token, secret)

      build_conn()
      |> with_basic_auth(user)
      |> get("/accounts")
      |> json_response(401)
    end
  end

  defp with_basic_auth(conn, username) do
    basic_auth = Base.encode64("#{username}:")

    conn
    |> put_req_header("authorization", "Basic #{basic_auth}")
  end
end
