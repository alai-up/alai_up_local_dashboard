
list(
  fluidRow(
    column(width=12,
           box(id = "time_trend_info_box",
                   title = "Instructions",
                   width = 12,
                   status = "info",
                   solidHeader = TRUE,
                   tagList(
                     p("foo"),
                     p("foo2")
                   )
               )
           )
  ),
  fluidRow(
    box(title = "cumulative events over time",
        width = 12,
        status = "primary", solidHeader = T,
        plotOutput("time_trend_total"),
        downloadButton(outputId = "time_trend_total_plot_download", label = "Download plot"),
        downloadButton(outputId = "time_trend_total_table_download",  
                       label = "Download table",
                       icon = icon("table")),
        size = "xs"
  ),
  box(title = "events over time",
        width = 12,
        status = "primary", solidHeader = T,
        plotOutput("time_trend_monthly"),
        downloadButton(outputId = "time_trend_monthly_plot_download", label = "Download plot"),
        downloadButton(outputId = "time_trend_monthly_table_download",  
                       label = "Download table",
                       icon = icon("table")),
        size = "xs"
  )
)
)
