defmodule Hangman.PdfUsersReport do

  @red "#ef5350"
  @foreground "#3c3c3c"

  def generate_pdf(items) do
    date = DateTime.utc_now()
    date_string = "#{date.year}/#{date.month}/#{date.day}"
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
          render_header(date_string),
          render_list(items)
        ]
      ])

      PdfGenerator.generate_binary(html, page_size: "Letter", shell_params: ["--dpi", "300"])
  end

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  defp render_header(date_string) do
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
                "padding-top" => "0px"
              })
          },
          "Usuarios"
        ],
        [
          :h3,
          %{
            style:
              style(%{
                "font-size" => "20px",
                "margin-top" => "-20px"
              })
          },
          date_string
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
            "Usuario"
          ],
          [
            :th,
            %{style: style(%{
              "border" => "1px solid #dddddd",
              "text-align" => "left",
              "padding" => "8px"
              })
            },
            "Accion"
          ],
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
            "Fecha"
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
        item.email
      ],
      [
        :td,
        %{style: style(%{
          "border" => "1px solid #dddddd",
          "text-align" => "left",
          "padding" => "8px"
          })
        },
        item.action
      ],
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
        item.inserted_at
      ]
    ]
  end
  # coveralls-ignore-stop
end
