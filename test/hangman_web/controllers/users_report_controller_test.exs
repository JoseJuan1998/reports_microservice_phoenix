defmodule HangmanWeb.UsersReportControllerTest do
  use HangmanWeb.ConnCase
  alias Hangman.Reports
  alias Hangman.Token

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[ANY] Token its invalid" do
    test "Error when 'token' invalid" do
      conn = build_conn()

      conn
      |> get(Routes.users_report_path(conn, :create_users_report_pdf))
      |> response(401)
    end
  end

  describe "GET /manager/report/users/pdf" do
    test "Create PDF" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.users_report_path(conn, :create_users_report_pdf))
        |> response(:ok)
    end
  end

  describe "GET /manager/reports/users/:np/:nr" do
    setup do
      {:ok, report} = Reports.create_users_report(%{"action" => "INSERT", "email" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns all users' reports" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.users_report_path(conn, :get_users_report, 1, 5))
        |> json_response(:ok)

      assert %{
        "count" => _count,
        "users_reports" => [%{
          "word" => _word,
          "action" => _difficulty,
          "date" => _played,
          "user" => _user
        }]
      } = response
    end

    test "Returns all users' reports matched" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.users_report_path(conn, :get_users_report, 1, 5, %{"char" => "a"}))
        |> json_response(:ok)

      assert %{
        "count" => _count,
        "users_reports" => [%{
          "word" => _word,
          "action" => _difficulty,
          "date" => _played,
          "user" => _user
        }]
      } = response
    end

    test "Returns no users" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.users_report_path(conn, :get_users_report))
        |> json_response(:ok)

      assert %{
        "error" => _error
      } = response
    end
  end
end
