defmodule Hangman.AMQP do
  def declare_queue(name) when is_atom(name) do
    # options = [host: "20.127.108.224", port: 5672, virtual_host: "/", username: "prueba", password: "prueba"]
    with  {:ok, connection} <- AMQP.Connection.open("amqp://prueba:prueba@20.127.108.224"),
          {:ok, channel} <- AMQP.Channel.open(connection),
          {:ok, queue} <- AMQP.Queue.declare(channel, Atom.to_string(name)),
          :ok <- AMQP.Connection.close(connection)
    do {:ok, queue} end
  end
end
