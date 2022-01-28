defmodule Hangman.Broadway do
  use Broadway

  alias Broadway.Message
  alias Hangman.AMQP
  alias Hangman.Reports

  def start_link(_opts) do
    case AMQP.declare_queue(:log) do
      {:ok, _queue} ->
        Broadway.start_link(__MODULE__,
          name: __MODULE__,
          producer: [
            module: {
              BroadwayRabbitMQ.Producer,
                  queue: "log",
                  connection: [
                    host: System.get_env("RABBIT_IP"),
                    port: 5672,
                    username: System.get_env("RABBIT_USER"),
                    password: System.get_env("RABBIT_PASS")
                  ],
                  on_failure: :reject, # reject_and_requeue,
                  qos: [prefetch_count: 50]
            },
            concurrency: 1
          ],
          processors: [
            default: [concurrency: 2]
          ]
        )
      {:error, :unknown_host} ->
        raise RuntimeError,
          "AMQP failed to declare the product queue."
      other -> other
    end
  end

  @impl true
  def handle_message(:default, %Message{data: data} = message, :context_not_set) do
    params = JSON.decode!(data)
    case params do
      %{
        "action" => _action,
        "email" => _email,
        "word" => _word,
      } ->
        case Reports.create_users_report(params) do
          {:ok, _report} -> IO.puts("Ok user report creted")
          {:error, _error} -> IO.puts("Failed")
        end
      %{
        "word" => _word,
        "user" => _user
      } ->
        case Reports.create_words_report(params) do
          {:ok, _word}-> IO.puts("Ok word report created")
          {:error, _error} ->
            case Reports.update_words_report_user(params) do
              {:ok, _updated} -> IO.puts("Ok word report updated")
              {:error, _error} -> IO.puts("Failed")
            end
        end
      %{
        "word" => _word
      } ->
        case Reports.update_words_report_played(params) do
          {:ok, _ok} -> IO.puts("Ok word report played updated")
          {:error, _error} -> IO.puts("Failed played updated")
        end
    end
    message
  end
end
