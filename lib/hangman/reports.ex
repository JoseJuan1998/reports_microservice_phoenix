defmodule Hangman.Reports do
  import Ecto.Query, warn: false
  alias Hangman.Repo
  alias Hangman.Reports.{
    UserReport,
    WordReport
  }

  def count_users_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["char"]) ->
        from u in UserReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.email, ^"%#{String.trim(String.downcase(attrs["char"]))}%") or like(u.action, ^"%#{String.trim(String.upcase(attrs["char"]))}%"), select: count(u)
      true ->
        from u in UserReport, select: count(u)
    end
    Repo.one(query)
  end

  def count_words_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["char"]) ->
        from u in WordReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.user, ^"%#{String.trim(String.downcase(attrs["char"]))}%"), select: count(u)
      true ->
        from u in WordReport, select: count(u)
    end
    Repo.one(query)
  end

  def all_users_report() do
    Repo.all(UserReport)
  end

  def all_words_report() do
    Repo.all(WordReport)
  end

  def list_users_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        attrs |> get_pagination_users()
      true ->
        from u in UserReport, offset: 0, limit: 0, select: u
    end
    Repo.all(query)
  end

  def create_users_report(attrs \\ %{}) do
    attrs
    |> UserReport.create_changeset()
    |> Repo.insert()
  end

  # def list_words_report() do
  #   WordReport
  #   |> Repo.all()
  # end

  def list_words_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        attrs |> get_pagination_words()
      true ->
        from u in UserReport, offset: 0, limit: 0, select: u
    end
    Repo.all(query)
  end

  def create_words_report(attrs \\ %{}) do
    attrs
    |> WordReport.create_changeset()
    |> Repo.insert()
  end

  def update_words_report_user(attrs \\ %{}) do
    attrs
    |> WordReport.update_user_changeset()
    |> Repo.update()
  end

  def update_words_report_played(attrs \\ %{}) do
    attrs
    |> WordReport.update_played_changeset()
    |> Repo.update()
  end

  def update_words_report_guessed(attrs \\ %{}) do
    attrs
    |> WordReport.update_guessed_changeset()
    |> Repo.update()
  end

  defp get_pagination_users(attrs) do
    cond do
      not is_nil(attrs["char"]) ->
        from u in UserReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.email, ^"%#{String.trim(String.downcase(attrs["char"]))}%") or like(u.action, ^"%#{String.trim(String.upcase(attrs["char"]))}%"), order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["max_date"]) and not is_nil(attrs["min_date"])->
        from u in UserReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.inserted_at >= ^NaiveDateTime.from_iso8601!(attrs["min_date"]<>" 00:00:00") and u.inserted_at <= ^NaiveDateTime.from_iso8601!(attrs["max_date"]<>" 11:59:59"), select: u
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field_users(attrs)
      true ->
        from u in UserReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_field_users(attrs) do
    case String.to_atom(String.downcase(attrs["field"])) do
      :word ->
        get_sorting_users(attrs)
      :email ->
        get_sorting_users(attrs)
      :action ->
        get_sorting_users(attrs)
      _other ->
        from u in UserReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_sorting_users(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        from u in UserReport, order_by: ^[asc: String.to_atom(String.downcase(attrs["field"]))], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      :DESC ->
        from u in UserReport, order_by: ^[desc: String.to_atom(String.downcase(attrs["field"]))],offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      _other ->
        from u in UserReport, order_by: [asc: u.word], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_pagination_words(attrs) do
    cond do
      not is_nil(attrs["char"]) ->
        from u in WordReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.user, ^"%#{String.trim(String.downcase(attrs["char"]))}%"), order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field_words(attrs)
      not is_nil(attrs["max_played"]) and not is_nil(attrs["min_played"])->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.played >= ^attrs["min_played"] and u.played <= ^attrs["max_played"], select: u
      not is_nil(attrs["min_guessed"]) and not is_nil(attrs["max_guessed"]) ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.guessed >= ^attrs["min_guessed"] and u.guessed <= ^attrs["max_guessed"], select: u
      true ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  # defp get_min(attrs) do
  #   min = min(attrs)
  #   case String.to_atom(String.downcase(attrs["min"])) do
  #     :played ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.played == ^min, select: u
  #     :guessed ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.guessed == ^min, select: u
  #     true ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  #   end
  # end

  # defp min(attrs) do
  #   case String.to_atom(String.downcase(attrs["min"])) do
  #     :played ->
  #       Repo.one(from u in WordReport, select: min(u.played))
  #     :guessed ->
  #       Repo.one(from u in WordReport, select: min(u.guessed))
  #     true -> 0
  #   end
  # end

  # defp get_max(attrs) do
  #   max = max(attrs)
  #   IO.puts("max")
  #   case String.to_atom(String.downcase(attrs["max"])) do
  #     :played ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.played == ^max, select: u
  #     :guessed ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.guessed == ^max, select: u
  #     true ->
  #       from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  #   end
  # end

  # defp max(attrs) do
  #   case String.to_atom(String.downcase(attrs["max"])) do
  #     :played ->
  #       Repo.one(from u in WordReport, select: max(u.played))
  #     :guessed ->
  #       Repo.one(from u in WordReport, select: max(u.guessed))
  #     true -> 0
  #   end
  # end

  defp get_field_words(attrs) do
    case String.to_atom(String.downcase(attrs["field"])) do
      :word ->
        get_sorting_words(attrs)
      :user ->
        get_sorting_words(attrs)
      _other ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end

  defp get_sorting_words(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        from u in WordReport, order_by: ^[asc: String.to_atom(String.downcase(attrs["field"]))], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      :DESC ->
        from u in WordReport, order_by: ^[desc: String.to_atom(String.downcase(attrs["field"]))],offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      _other ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
    end
  end
end
