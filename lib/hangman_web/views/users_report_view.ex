defmodule HangmanWeb.UsersReportView do
  use HangmanWeb, :view

  def render("reports.json", %{reports: reports}) do
    %{users_reports: render_many(reports, HangmanWeb.UsersReportView, "single_report.json")}
  end

  def render("single_report.json", %{users_report: report}) do
    %{
      user: report.email,
      word: report.word,
      action: report.action,
      date: report.inserted_at
    }
  end
end
