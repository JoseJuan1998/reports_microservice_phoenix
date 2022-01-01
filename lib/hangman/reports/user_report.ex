defmodule Hangman.Reports.UserReport do
  import Ecto.Changeset
  use Ecto.Schema
  alias Hangman.Repo

  schema "users_report" do
    field :email, :string
    field :word, :string
    field :action, :string

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :word, :action])
    |> validate_required([:email, :word, :action])
  end
end
