
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
        # dataTableOutput("time_trend_out1"),
        # downloadButton(outputId = "data_explore_plot_download", label = "Download plot"),
        # downloadButton(outputId = "data_explore_table_download",  
        #                label = "Download table",
        #                icon = icon("table")),
        size = "xs"
  ),
  box(title = "events over time",
        width = 12,
        status = "primary", solidHeader = T,
        plotOutput("time_trend_monthly"),
        # downloadButton(outputId = "data_explore_plot_download", label = "Download plot"),
        # downloadButton(outputId = "data_explore_table_download",  
        #                label = "Download table",
        #                icon = icon("table")),
        size = "xs"
  )
)
)
