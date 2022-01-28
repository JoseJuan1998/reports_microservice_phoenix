defmodule HangmanWeb.UsersReportController do
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger
  use HangmanWeb, :controller
  alias Hangman.Reports
  alias Hangman.PdfUsersReport

  # coveralls-ignore-start
  def swagger_definitions do
    %{
      UsersReport:
        swagger_schema do
          title("Users Report")
          description("Users report to handle")

          properties do
            id(:integer, "Report ID")
            email(:string, "User's email that make a change", required: true)
            action(:string, "Action made")
            word(:string, "Word handled")
            inserted_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Update timestamp", format: :datetime)
          end
        end,
      GetUserReportResponse:
        swagger_schema do
          title("GetWordsResponse")
          description("Response of users report")
          example(%{
            count: 2,
            user_report: [
              %{
                word: "APPLE",
                action: "INSERT",
                date: "2021-12-21T03:06:06"
              },
              %{
                word: "LION",
                action: "INSERT",
                date: "2021-12-21T03:06:06"
              }
            ]
          })
        end,
        GetUserReportResponseError:
        swagger_schema do
          title("GetWordsResponseError")
          description("Response of error")
          example(%{
            error: "There are no reports"
          })
        end
    }
  end

  swagger_path :get_users_report do
    get("/manager/report/users/:np/:nr?char={char}&field={field}&order={order}&min_date={min_date}&max_date={max_date}")
    summary("Users' report")
    description("Returns JSON with the report")
    parameters do
      authorization :header, :string, "Token to access", required: true
      np :path, :string, "Page number", required: true
      nr :path, :string, "Rows number", required: true
      char :path, :string, "Report to match", required: false
      field :path, :string, "Field to order", required: false
      order :path, :string, "Order", required: false
      min_date :path, :string, "Min date to search", required: false
      max_date :path, :string, "Max date to search", required: false
    end
    response(200, "Success", Schema.ref(:GetUserReportResponse))
    response(204, "No reports" ,Schema.ref(:GetUserReportResponseError))
  end

  # coveralls-ignore-stop

  def get_users_report(conn, params) do
    reports = Reports.list_users_report(params)
    case reports != [] do
      true ->
        count = Reports.count_users_report(params)
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
  swagger_path :create_users_report_pdf do
    get("/manager/report/users/pdf")
    summary("Users' report pdf")
    description("Returns JSON with the path")
    parameters do
      authorization :header, :string, "Token to access", required: true
    end
    response(200, "Success")
  end
  # coveralls-ignore-stop

  def create_users_report_pdf(conn, _params) do
    date = DateTime.utc_now()
    date_pdf = "#{date.year}_#{date.month}_#{date.day}_#{date.hour}:#{date.minute}:#{date.second}"
    {:ok, binary} = PdfUsersReport.generate_pdf(Reports.all_users_report)
    conn
    |> put_status(:ok)
    |> send_download({:binary, binary}, filename: "users_report_"<>date_pdf<>".pdf")
  end
end
