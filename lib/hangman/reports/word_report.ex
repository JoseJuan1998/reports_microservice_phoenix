defmodule Hangman.Reports.WordReport do
  import Ecto.Changeset
  use Ecto.Schema
  alias Hangman.Repo

  schema "words_report" do
    field :word, :string
    field :played, :integer
    field :guessed, :integer
    field :user, :string

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:word, :user])
    |> validate_required([:word, :user])
    |> setup_create()
    |> unique_constraint(:word, message: "Report already exists")
  end

  def update_user_changeset(attrs) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:user])
    |> validate_required([:user])
  end

  def update_played_changeset(attrs) do
    attrs
    |> get_changeset()
    |> set_changeset_played()
  end

  def update_guessed_changeset(attrs) do
    attrs
    |> get_changeset()
    |> set_changeset_guessed()
  end

  defp set_changeset_guessed(%{valid?: false} = changeset), do: changeset

  defp set_changeset_guessed(report) do
    Ecto.Changeset.change(report, guessed: report.guessed + 1)
  end

  defp set_changeset_played(%{valid?: false} = changeset) , do: changeset

  defp set_changeset_played(report) do
    Ecto.Changeset.change(report, played: report.played + 1)
  end

  defp get_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> get_report()
  end

  defp get_report(%{valid?: false} = changeset), do: changeset

  defp get_report(%{valid?: true} = changeset) do
    case Repo.get_by(__MODULE__, word: get_field(changeset, :word)) do
      nil -> add_error(changeset, :word, "Report not found")
      report -> report
    end
  end

  defp setup_create(%{valid?: false} = changeset), do: changeset

  defp setup_create(%{valid?: true} = changeset) do
    changeset
    |> put_change(:played, 0)
    |> put_change(:guessed, 0)
  end
end
