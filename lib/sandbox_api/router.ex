defmodule SandboxAPI.Router do
  use Phoenix.Router

  # import Plug.Conn

  pipeline :api do
    plug(:accepts, ["json"])
    plug(SandboxAPI.Plugs.Accounts)
  end

  pipeline :account do
    plug(SandboxAPI.Plugs.Account)
  end

  pipeline :transactions do
    plug(SandboxAPI.Plugs.Transactions)
  end

  pipeline :transaction do
    plug(SandboxAPI.Plugs.Transaction)
  end

  scope "/accounts", SandboxAPI do
    pipe_through(:api)

    get("/", Controller, :list)

    scope "/:account_id" do
      pipe_through(:account)

      get("/", Controller, :account)
      get("/details", Controller, :details)

      scope "/balances" do
        pipe_through(:transactions)

        get("/", Controller, :balances)
      end

      scope "/transactions" do
        pipe_through(:transactions)
        get("/", Controller, :transactions)

        scope "/:transaction_id" do
          pipe_through(:transaction)
          get("/", Controller, :transaction)
        end
      end
    end
  end
end
