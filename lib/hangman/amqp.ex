defmodule Hangman.AMQP do
  def declare_queue(name) when is_atom(name) do
    with  {:ok, connection} <- AMQP.Connection.open(System.get_env("RABBIT_URL"), port: 5673),
          {:ok, channel} <- AMQP.Channel.open(connection),
          {:ok, queue} <- AMQP.Queue.declare(channel, Atom.to_string(name)),
          :ok <- AMQP.Connection.close(connection)
    do {:ok, queue} end
  end
end
