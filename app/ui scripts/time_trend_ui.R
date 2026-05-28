
list(
  fluidRow(
    column(width=12,
           box(id = "time_trend_info_box",
                   title = "Instructions",
                   width = 12,
                   status = "info",
                   solidHeader = TRUE,
                   tagList(
                     p("The Time Trends page allows you to explore changes in indicators and 
                        subindicators over time stratified by demographics and social deteminants of health.
                        This facilitates comparison across subgroups to determine if care gaps have
                        changed over time at your clinic."),
                     p("The first plot shows the cumulative percentage of a given indicator over time
                        for each group within a demographic group. For example, if the indicator is 'Assessed' 
                        and the demographic group is age, the plot will show the total percentage
                        assessed for each age group over time. The denominator for each line is the total
                        number of people in that age group."),
                     p("The second plot shows the monthly percentage of a given indicator over time
                        for each group within a demographic group. For example, if the indicator is 'Assessed' 
                        and the demographic group is age, the plot will show the total percentage
                        assessed for each age group in each month over time. The denominator for each line is the total
                        number of people in that age group."),
                     p("There are several inputs you can modify:"),
                     tags$ul(
                        tags$li('Indicator: the indicator shown in the plots'),
                        tags$li('Comparison variable: the demographic or social determinant of health category
                                 you are interested in comparing'),
                        tags$li('Range of date: the range of dates to focus on in the graphs, allowing you to 
                                 zoom in on a particular period'),
                        tags$li('Time period length: controls whether the data are aggregated monthly (1 month),
                                 quarterly (3 months) or biannually (6 months)')
                      )
                   )
               )
           )
  ),
  fluidRow(
    box(title = "Total events over time by group",
        width = 12,
        status = "primary", solidHeader = T,
        plotOutput("time_trend_total"),
        downloadButton(outputId = "time_trend_total_plot_download", label = "Download plot"),
        downloadButton(outputId = "time_trend_total_table_download",  
                       label = "Download table",
                       icon = icon("table")),
        size = "xs"
  ),
  box(title = "Events over time by group",
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
