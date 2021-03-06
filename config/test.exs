import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hangman, Hangman.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "reports",
  database: "reports_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hangman, HangmanWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4050],
  secret_key_base: "NNfVm8DR/0mW4Azn5gPDUuDy3R25VbmcquCidX25XODKSq1ae/eGy9RPllY6z8RL",
  server: false

# config :hangman, BroadwayRabbitMQ.Producer, {Broadway.DummyProducer, []}

# In test we don't send emails.
config :hangman, Hangman.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
