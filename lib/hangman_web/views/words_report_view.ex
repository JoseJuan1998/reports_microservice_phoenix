defmodule HangmanWeb.WordsReportView do
  use HangmanWeb, :view

  def render("reports.json", %{count: count, reports: reports}) do
    %{count: count, words_reports: render_many(reports, HangmanWeb.WordsReportView, "single_report.json")}
  end

  def render("single_report.json", %{words_report: report}) do
    %{
      word: report.word,
      user: report.user,
      played: report.played,
      guessed: report.guessed
    }
  end
end
