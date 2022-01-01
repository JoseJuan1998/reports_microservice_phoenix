defmodule Hangman.Repo.Migrations.CreateWordsReport do
  use Ecto.Migration

  def change do
    create table(:words_report) do
      add :word, :string
      add :played, :integer
      add :guessed, :integer
      add :user, :string

      timestamps()
    end
    create unique_index(:words_report, [:word])
  end
end
