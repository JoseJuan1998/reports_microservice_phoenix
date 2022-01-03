defmodule HangmanWeb.WordsReportControllerTest do
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
      |> get(Routes.words_report_path(conn, :create_words_report_pdf))
      |> response(401)
    end
  end

  describe "GET /manager/report/words/pdf" do
    test "Create PDF" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.words_report_path(conn, :create_words_report_pdf))
        |> response(:ok)
    end
  end

  describe "GET /manager/reports/words/:np/:nr" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns all words' reports" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.words_report_path(conn, :get_words_report, 1, 5))
        |> json_response(:ok)

      assert %{
        "words_reports" => [%{
          "word" => _word,
          "guessed" => _difficulty,
          "played" => _played,
          "user" => _user
        }]
      } = response
    end

    test "Returns no words" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> get(Routes.words_report_path(conn, :get_words_report))
        |> json_response(:ok)

      assert %{
        "error" => _error
      } = response
    end
  end

  describe "PUT /manager/reports/words/guessed" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Update the word" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> put(Routes.words_report_path(conn, :update_words_guessed, %{"word" => "APPLE"}))
        |> json_response(205)

      assert %{
        "ok" => _error
      } = response
    end

    test "Not update the word" do
      conn = build_conn()

      response =
        conn
        |> put_req_header("authorization", Token.auth_sign(%{email: "juan@mail.com", user_id: 1}))
        |> put(Routes.words_report_path(conn, :update_words_guessed, %{"word" => "LLLL"}))
        |> json_response(404)

      assert %{
        "error" => _error
      } = response
    end
  end
end
