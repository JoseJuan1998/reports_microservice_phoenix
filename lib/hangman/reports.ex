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
        from u in search_users_report(attrs), select: count(u)
      true ->
        from u in UserReport, select: count(u)
    end
    Repo.one(query)
  end

  def count_words_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["char"]) ->
        from u in search_words_report(attrs), select: count(u)
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

  def list_words_report(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        attrs |> get_pagination_words()
      true ->
        from u in WordReport, offset: 0, limit: 0, select: u
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
        from u in search_users_report(attrs), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["max_date"]) and not is_nil(attrs["min_date"])->
        get_date(attrs)
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field_users(attrs)
      true ->
        from u in paginate_users_report(attrs), select: u
    end
  end

  defp get_date(attrs) do
    case NaiveDateTime.from_iso8601(attrs["min_date"]<>" 00:00:00") != {:error, :invalid_format} and NaiveDateTime.from_iso8601(attrs["max_date"]<>" 00:00:00") != {:error, :invalid_format} do
      false ->
        from u in UserReport, offset: 0, limit: 0, select: u
      true ->
        from u in paginate_users_report(attrs), where: u.inserted_at >= ^NaiveDateTime.from_iso8601!(attrs["min_date"]<>" 00:00:00") and u.inserted_at <= ^NaiveDateTime.from_iso8601!(attrs["max_date"]<>" 11:59:59"), select: u
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
        from u in paginate_users_report(attrs), select: u
    end
  end

  defp get_sorting_users(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        sort_users_report(:asc, attrs)
      :DESC ->
        sort_users_report(:desc, attrs)
      _other ->
        from u in paginate_users_report(attrs), select: u
    end
  end

  defp get_pagination_words(attrs) do
    cond do
      not is_nil(attrs["char"]) ->
        from u in search_words_report(attrs), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field_words(attrs)
      not is_nil(attrs["max_played"]) and not is_nil(attrs["min_played"])->
        integer_played(attrs)
      not is_nil(attrs["min_guessed"]) and not is_nil(attrs["max_guessed"]) ->
        integer_guessed(attrs)
      true ->
        paginate_words_report(attrs)
    end
  end

  defp integer_played(attrs) do
    cond do
      is_integer(attrs["min_played"]) and is_integer(attrs["max_played"]) ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.played >= ^abs(attrs["min_played"]) and u.played <= ^abs(attrs["max_played"]), select: u
      true ->
        from u in WordReport, offset: 0, limit: 0, select: u
    end
  end

  defp integer_guessed(attrs) do
    cond do
      is_integer(attrs["min_guessed"]) and is_integer(attrs["max_guessed"]) ->
        from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], where: u.guessed >= ^abs(attrs["min_guessed"]) and u.guessed <= ^abs(attrs["max_guessed"]), select: u
      true ->
        from u in WordReport, offset: 0, limit: 0, select: u
    end
  end

  defp get_field_words(attrs) do
    case String.to_atom(String.downcase(attrs["field"])) do
      :word ->
        get_sorting_words(attrs)
      :user ->
        get_sorting_words(attrs)
      _other ->
        paginate_words_report(attrs)
    end
  end

  defp get_sorting_words(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        sort_words_report(:asc, attrs)
      :DESC ->
        sort_words_report(:desc, attrs)
      _other ->
        paginate_words_report(attrs)
    end
  end

  defp search_users_report(attrs) do
    from u in UserReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.email, ^"%#{String.trim(String.downcase(attrs["char"]))}%") or like(u.action, ^"%#{String.trim(String.upcase(attrs["char"]))}%")
  end

  defp sort_users_report(order, attrs) do
    from u in UserReport, order_by: ^Keyword.new([{order, String.to_atom(String.downcase(attrs["field"]))}]), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  end

  defp paginate_users_report(attrs) do
    from u in UserReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"]
  end

  defp search_words_report(attrs) do
    from u in WordReport, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%") or like(u.user, ^"%#{String.trim(String.downcase(attrs["char"]))}%")
  end

  defp sort_words_report(order, attrs) do
    from u in WordReport, order_by: ^Keyword.new([{order, String.to_atom(String.downcase(attrs["field"]))}]), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  end

  defp paginate_words_report(attrs) do
    from u in WordReport, order_by: [asc: u.inserted_at], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  end
end
