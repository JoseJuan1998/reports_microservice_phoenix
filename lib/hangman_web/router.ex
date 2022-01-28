defmodule HangmanWeb.Router do
  use HangmanWeb, :router

  pipeline :api do
    plug CORSPlug,
    send_preflight_response?: false,
    origin: [
      "http://localhost:3000"
    ]
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug HangmanWeb.Auth.PipelineAccess
  end

  scope "/manager", HangmanWeb do
    pipe_through [:api, :auth]

    get "/report/users/:np/:nr", UsersReportController, :get_users_report
    get "/report/users", UsersReportController, :get_users_report
    get "/report/users/pdf", UsersReportController, :create_users_report_pdf
    get "/report/words/:np/:nr", WordsReportController, :get_words_report
    get "/report/words", WordsReportController, :get_words_report
    get "/report/words/pdf", WordsReportController, :create_words_report_pdf
  end

  scope "/manager", HangmanWeb do
    pipe_through :api
    options "/", OptionsController, :options
    options "/report/users/:np/:nr", OptionsController, :options
    options "/report/users/pdf", OptionsController, :options
    options "/report/words/:np/:nr", OptionsController, :options
    options "/report/words/guessed", OptionsController, :options
    options "/report/words/pdf", OptionsController, :options

    put "/report/words/guessed", WordsReportController, :update_words_guessed
  end

# coveralls-ignore-start
  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Reports API"
      }
    }
  end
  # coveralls-ignore-stop

  scope "/manager/doc" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
    otp_app: :hangman,
    swagger_file: "swagger.json"
  end
end
