defmodule Hangman.Repo.Migrations.CreateUsersReport do
  use Ecto.Migration

  def change do
    create table(:users_report) do
      add :email, :string
      add :word, :string
      add :action, :string

      timestamps()
    end
  end
end
