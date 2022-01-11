defmodule Hangman.ReportTest do
  use Hangman.DataCase
  alias Hangman.Reports

  ## MIX_ENV=test mix coveralls
  ## MIX_ENV=test mix coveralls.html

  # --- Unit Tests -------------------------------------------------------------------------------

  describe "[Unit] list_users_report():" do
    setup do
      {:ok, report} = Reports.create_users_report(%{"action" => "INSERT", "email" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns all user reports" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1"})
      assert reports != []
    end

    test "Returns all user reports by date" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "min_date" => "2022-01-01", "max_date" => "2022-01-30"})
      assert reports != []
    end

    test "Returns user report that match" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "char" => "juan"})
      assert reports != []
    end

    test "Returns user report ordered ASC email" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "email", "order" => "asc"})
      assert reports != []
    end

    test "Returns users" do
      reports = Reports.all_users_report()
      assert reports != []
    end

    test "Returns user report ordered ASC word" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "word", "order" => "asc"})
      assert reports != []
    end

    test "Returns user report ordered ASC action" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "action", "order" => "asc"})
      assert reports != []
    end

    test "Returns user report ordered DESC" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "email", "order" => "desc"})
      assert reports != []
    end

    test "Returns all when field wrong" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "asdf", "order" => "desc"})
      assert reports != []
    end

    test "Returns all when order wrong" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "field" => "email", "order" => "asdf"})
      assert reports != []
    end

    test "Error when user reports is empty" do
      reports = Reports.list_users_report()
      assert reports == []
    end

    test "Error when user reports is empty by wrong date" do
      reports = Reports.list_users_report(%{"np" => "1","nr" =>"1", "min_date" => "ASDF", "max_date" => "ASDF"})
      assert reports == []
    end
  end

  describe "[Unit] create_users_report():" do
    test "Returns the user created" do
      assert {:ok, report} = Reports.create_users_report(%{"action" => "INSERT", "email" => "juan@mail.com", "word" => "APPLE"})
    end
  end

  describe "[Unit] list_words_report():" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns all words reports" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1"})
      assert reports != []
    end

    test "Returns words that match" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","char" => "a"})
      assert reports != []
    end

    test "Returns words order ASC" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","field" => "word", "order" => "asc"})
      assert reports != []
    end

    test "Returns words order DESC" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","field" => "user", "order" => "desc"})
      assert reports != []
    end

    test "Returns words" do
      reports = Reports.all_words_report()
      assert reports != []
    end

    test "Returns all when field wrong" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","field" => "asdf", "order" => "desc"})
      assert reports != []
    end

    test "Returns all when order wrong" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","field" => "user", "order" => "asdf"})
      assert reports != []
    end

    test "Error when word reports is empty" do
      reports = Reports.list_words_report()
      assert reports == []
    end

    test "Error when word reports is empty by wrong type not integer played" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1", "min_played" => "1", "max_played" => "1"})
      assert reports == []
    end

    test "Error when word reports is empty by wrong type not integer guessed" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1", "min_guessed" => "1", "max_guessed" => "1"})
      assert reports == []
    end

    test "Returns a range of played words" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","min_played" => 0, "max_played" => 1})
      assert reports != []
    end

    test "Returns a range of guessed words" do
      reports = Reports.list_words_report(%{"np" => "1","nr" =>"1","min_guessed" => 0, "max_guessed" => 1})
      assert reports != []
    end
  end

  describe "[Unit] create_words_report():" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Error if word exists" do
      assert {:error, changeset} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      Hangman.DataCase.errors_on(changeset)
    end

    test "Error if word data is wrong" do
      assert {:error, _error} = Reports.create_words_report(%{})
    end
  end

  describe "[Unit] update_words_report_user():" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returs word report updated" do
      assert {:ok, report} = Reports.update_words_report_user(%{"user" => "juan@mail.com", "word" => "APPLE"})
    end

    test "Error when word not exists" do
      assert {:error, _error} = Reports.update_words_report_user(%{"user" => "juan@mail.com", "word" => "LION"})
    end

    test "Error when word data not exists" do
      assert {:error, _error} = Reports.update_words_report_user(%{})
    end
  end

  describe "[Unit] update_words_report_played():" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns the report of word updated" do
      assert {:ok, report} = Reports.update_words_report_played(%{"word" => "APPLE"})
    end

    test "Error when word data not exists" do
      assert {:error, _error} = Reports.update_words_report_played(%{})
    end
  end

  describe "[Unit] update_words_report_guessed():" do
    setup do
      {:ok, report} = Reports.create_words_report(%{"user" => "juan@mail.com", "word" => "APPLE"})
      {:ok, report: report}
    end

    test "Returns the report of word updated" do
      assert {:ok, report} = Reports.update_words_report_guessed(%{"word" => "APPLE"})
    end

    test "Error when word data not exists" do
      assert {:error, _error} = Reports.update_words_report_guessed(%{})
    end
  end
end
