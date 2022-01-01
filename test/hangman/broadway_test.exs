defmodule Hangman.Broadway do
  use ExUnit.Case, async: true

  test "test message" do
    Broadway.test_message(Hangman.Broadway, 1)
  end
end
