defmodule Hangman.PdfWordsReport do

  @red "#ef5350"
  @foreground "#3c3c3c"

  def generate_pdf(items) do
    date = NaiveDateTime.local_now()
    date_header = "Fecha: #{date.year}/#{date.month}/#{date.day}"
    time_header = "Hora: #{date.hour}:#{date.minute}:#{date.second}"
    html =
      Sneeze.render([
        :html,
        [
          :body,
          %{
            style:
              style(%{
                "font-family" => "Helvetica",
                "font-size" => "20px",
                "color" => @foreground
              })
          },
          render_header(date_header, time_header, Enum.count(items)),
          render_list(items)
        ]
      ])

      PdfGenerator.generate_binary(html, page_size: "Letter", shell_params: ["--dpi", "300", "--footer-right", "Página [page] de [topage]", "--margin-bottom", "15mm", "--footer-spacing", "2", "--footer-font-size", "10"])
  end

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  defp render_header(date, time, count) do
    [
      :div,
      %{
        style:
          style(%{
            "display" => "flex",
            "flex-direction" => "column",
            "align-items" => "flex-start",
            "margin-bottom" => "20px"
          })
      },
      [
        :div,
        %{
          style:
            style(%{
              "display" => "inline-block",
              "position" => "relative",
              "padding-left" => "20px",
              "margin-top" => "10px"
            })
        },
        [
          :h1,
          %{
            style:
              style(%{
                "font-size" => "35px",
                "color" => @red,
                "margin-top" => "0px",
                "padding-top" => "0px",
                "margin-left" => "-16px"
              })
          },
          "Palabras"
        ],
        [
          :h3,
          %{
            style:
              style(%{
                "font-size" => "20px",
                "margin-top" => "-20px",
                "margin-left" => "-16px"
              })
          },
          date
        ],
        [
          :h3,
          %{
            style:
              style(%{
                "font-size" => "20px",
                "margin-top" => "-15px",
                "margin-bottom" => "20px",
                "margin-left" => "-16px"
              })
          },
          time
        ],
        [
          :h3,
          %{
            style:
              style(%{
                "font-size" => "16px",
                "margin-bottom" => "-15px",
                "margin-left" => "-16px"
              })
          },
          "Total de Registros: #{count}"
        ]
      ]
    ]
  end

  defp render_list(items) do
    list = [
      :table,
      %{style: style(%{
        "font-family" => "arial, sans-serif",
        "border-collapse" => "collapse",
        "width" => "100%"
        })
      },
        [:tr,
          [
            :th,
            %{style: style(%{
              "border" => "1px solid #dddddd",
              "text-align" => "left",
              "padding" => "8px"
              })
            },
            "Palabra"
          ],
          [
            :th,
            %{style: style(%{
              "border" => "1px solid #dddddd",
              "text-align" => "left",
              "padding" => "8px"
              })
            },
            "Gestor"
          ],
          [
            :th,
            %{style: style(%{
              "border" => "1px solid #dddddd",
              "text-align" => "left",
              "padding" => "8px"
              })
            },
            "Jugada"
          ],
          [
            :th,
            %{style: style(%{
              "border" => "1px solid #dddddd",
              "text-align" => "left",
              "padding" => "8px"
              })
            },
            "Adivinada"
          ]
        ]
    ]
    list_items = Enum.map(items, &render_item/1)
    list ++ list_items
  end

  # coveralls-ignore-start
  defp render_item(item) do
    [
      :tr,
      [
        :td,
        %{style: style(%{
          "border" => "1px solid #dddddd",
          "text-align" => "left",
          "padding" => "8px"
          })
        },
        item.word
      ],
      [
        :td,
        %{style: style(%{
          "border" => "1px solid #dddddd",
          "text-align" => "left",
          "padding" => "8px"
          })
        },
        item.user
      ],
      [
        :td,
        %{style: style(%{
          "border" => "1px solid #dddddd",
          "text-align" => "left",
          "padding" => "8px"
          })
        },
        item.played
      ],
      [
        :td,
        %{style: style(%{
          "border" => "1px solid #dddddd",
          "text-align" => "left",
          "padding" => "8px"
          })
        },
        item.guessed
      ]
    ]
  end
  # coveralls-ignore-stop
end
