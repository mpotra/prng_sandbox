# Sandbox

Teller Test API application, using pseudo-random number generator (PRNG) to generate pseudo-random data based on https://teller.io/docs/api/2020-10-12

## Application components

The application is composed of 3 main parts:
- Sandbox modules, including Data models.
- Sandbox API - a Plug-based API server
- Sandbox Web - a Phoenix server used for querying metrics (metrics NOT IMPLEMENTED)



## How does the generator work

Using Erlang's `:rand` [module](https://erlang.org/doc/man/rand.htm), data is generated pseudo-randomly using a [`state`](https://erlang.org/doc/man/rand.html#type-export_state) that is encoded in an access Token.

Storing this rand state in the Token ensures that regardless of the time or setup, the API generates the same information over and over.

### Generating the access Token

Access to the Sandbox API is done via the `Authentication` header in the request, using `Basic` base64 encoded authentication, comprised of a `<test_token>:<password>` credentials, where:
- `<test_token>` username is the access Token in format `test_<TOKEN>`
- `<password>` is an empty string

The `<TOKEN>` string is a base64 encoded binary of a [`%Sandbox.Token{}`](https://github.com/mpotra/teller_sandbox/blob/main/lib/sandbox/token.ex) struct that is encrypted with a salt. The [`%Sandbox.Token{}`](https://github.com/mpotra/teller_sandbox/blob/main/lib/sandbox/token.ex) struct holds the PRNG seed state, its `state` key.

Default salt for encrypting the token is `"my secret token"`, set up in the `:sandbox` application configuration [under `:token_secret` key](https://github.com/mpotra/teller_sandbox/blob/main/config/config.exs#L11).

#### Generating a new token

In order to generate a new token, there is a mix command available:
```
mix gen_token
```

The command will output the new `test_<TOKEN>` string, which you can use as `username` in the `Basic Authorization` header.

#### Generating Transactions by date

Given the pseudo-random property of the `:rand` algorithms, each date can be represented as a new `state` derived out of the base `state`.
Deriving the date `state` is done by multiplying the date as `YYYYMMDD` integer with the base `state`.
This ensures that regardless of the state stored in the token, each `date` can be represented as a 

## Installing and starting the application

**Note: Erlang 18+ is required**, due to the changes (additions and deprecations) in the `:rand` and `:random` modules.

To set up and start the application, run the following commands in the project directory:

```
asdf install

mix deps.get
mix phx.server
```

Optionally, install Node.js dependencies with `npm install` inside the `assets` directory


### Accessing the Sandbox API server

The server is by default running at [`localhost:4000`](http://localhost:4000) with the following endpoints:

- `GET /accounts` - [http://localhost:4000/accounts](http://localhost:4000/accounts)
- `GET /accounts/:account_id` - [http://localhost:4000/accounts/:account_id`](http://localhost:4000/accounts/:account_id)
- `GET /accounts/:account_id/details` - [http://localhost:4000/accounts/:account_id/details](http://localhost:4000/accounts/:account_id/details)
- `GET /accounts/:account_id/balances` - [http://localhost:4000/accounts/:account_id/balances](http://localhost:4000/accounts/:account_id/balances)
- `GET /accounts/:account_id/transactions` - [http://localhost:4000/accounts/:account_id/transactions](http://localhost:4000/accounts/:account_id/transactions)
- `GET /accounts/:account_id/transactions/:transaction_id` - [http://localhost:4000/accounts/:account_id/transactions/:transaction_id](http://localhost:4000/accounts/:account_id/transactions/:transaction_id)

The `/accounts/:account_id/transactions` endpoint supports the following query params:
- `count=<N::integer>` - the number of entries to return. Must be a non negative integer.
- `from_id=<TransactionID::string>` - return transactions older than given `TransactionID`

### Tests

```
mix dialyzer
mix test
```

### Data store

The random data generator uses JSON files stores in `./data` directory, as a source for Merchant names, Account names, Institution names and Merchant categories; as opposed to hardcoding the values.

### The Phoenix server

The Phoenix application is by default running on [`localhost:4001`](http://localhost:4001)

However, at this time, there is nothing running inside.