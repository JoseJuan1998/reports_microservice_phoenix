defmodule HangmanWeb.WordsReportController do
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger
  use HangmanWeb, :controller
  alias Hangman.Reports
  alias Hangman.PdfWordsReport

  action_fallback HangmanWeb.ReportErrorController

  # coveralls-ignore-start
  def swagger_definitions do
    %{
      WordsReport:
        swagger_schema do
          title("Words Report")
          description("Words report to handle")

          properties do
            id(:integer, "Report ID")
            word(:string, "Word")
            user(:string, "User's email that create the word", required: true)
            played(:string, "Times that word has been played")
            guessed(:string, "Times that word has been guessed")
            inserted_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Update timestamp", format: :datetime)
          end
        end,
      GetWordReportResponse:
        swagger_schema do
          title("GetWordsResponse")
          description("Response of words report")
          example(%{
            count: 2,
            words_reports: [
              %{
                word: "APPLE",
                user: "juan@mail.com",
                played: 0,
                guessed: 0
              },
              %{
                word: "LION",
                user: "juan@mail.com",
                played: 0,
                guessed: 0
              }
            ]
          })
        end,
        GetWordReportResponseError:
        swagger_schema do
          title("GetWordsResponseError")
          description("Response of error")
          example(%{
            error: "There are no reports"
          })
        end,
        UpdateWordsGuessedRequest:
        swagger_schema do
          title("UpdateWordsGuessed")
          description("Returns JSON with the report")
          example %{
            word: "APPLE"
          }
        end,
        UpdateWordsGuessedResponse:
        swagger_schema do
          title("UpdateWordsGuessedResponse")
          description("Returns JSON with the ok")
          example %{
            ok: "Updated word guessed"
          }
        end,
        UpdateWordsGuessedError:
        swagger_schema do
          title("UpdateWordsGuessedError")
          description("Returns JSON with the error")
          example %{
            error: "Failed updating guessed word"
          }
        end
    }
  end

  swagger_path :get_words_report do
    get("/manager/report/words/:np/:nr?char={char}&field={field}&order={order}&max_played={max_played}&min_played={min_played}&max_guessed={max_guessed}&min_guessed={min_guessed}")
    summary("Words' report")
    description("Returns JSON with the report")
    parameters do
      authorization :header, :string, "Token to access", required: true
      np :path, :string, "Page number", required: true
      nr :path, :string, "Rows number", required: true
      char :path, :string, "Report to match", required: false
      field :path, :string, "Field to order", required: false
      order :path, :string, "Order", required: false
      max_played :path, :string, "Max played", required: false
      min_played  :path, :string, "Min played", required: false
      max_guessed :path, :string, "Max guessed", required: false
      min_guessed :path, :string, "Min guessed", required: false
    end
    response(200, "Success", Schema.ref(:GetWordReportResponse))
    response(204, "No reports" ,Schema.ref(:GetWordReportResponseError))
  end

  # coveralls-ignore-stop

  def get_words_report(conn, params) do
    reports = Reports.list_words_report(params)

    case reports != [] do
      true ->
        count = Reports.count_words_report(params)
        conn
        |> put_status(200)
        |> render("reports.json", %{count: count, reports: reports})
      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no reports"})
    end
  end

  # coveralls-ignore-start
  swagger_path :update_words_guessed do
    put("/manager/report/words/guessed")
    summary("Update guessed word")
    description("Returns JSON with the report")
    parameters do
      authorization :header, :string, "Token to access", required: true
      word :body, Schema.ref(:UpdateWordsGuessedRequest), "The word data", required: true
    end
    response(205, "Success", Schema.ref(:UpdateWordsGuessedResponse))
    response(404, "No report found" ,Schema.ref(:UpdateWordsGuessedError))
  end
  # coveralls-ignore-stop


  def update_words_guessed(conn, params) do
    case Reports.update_words_report_guessed(params) do
      {:ok, _report} ->
        IO.puts("Ok word report guessed updated")
        conn
        |> put_status(205)
        |> json(%{ok: "Updated guessed word"})
      {:error, _changeset} ->
        IO.puts("Failed updating guessed word")
        conn
        |> put_status(404)
        |> json(%{error: "Failed updating guessed word"})
    end
  end

  # coveralls-ignore-start
  swagger_path :create_words_report_pdf do
    get("/manager/report/words/pdf")
    summary("Words' report pdf")
    description("Returns JSON with the path")
    parameters do
      authorization :header, :string, "Token to access", required: true
    end
    response(200, "Success")
  end
  # coveralls-ignore-stop

  def create_words_report_pdf(conn, _params) do
    date = DateTime.utc_now()
    date_pdf = "#{date.year}_#{date.month}_#{date.day}_#{date.hour}:#{date.minute}:#{date.second}"
    {:ok, binary} = PdfWordsReport.generate_pdf(Reports.all_words_report)
    conn
    |> put_status(:ok)
    |> send_download({:binary, binary}, filename: "words_report_"<>date_pdf<>".pdf")
  end
end
