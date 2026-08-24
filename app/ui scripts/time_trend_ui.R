
list(
  fluidRow(
    column(width=12,
           box(id = "time_trend_info_box",
                   title = "Instructions",
                   width = 12,
                   status = "info",
                   solidHeader = TRUE,
                   tagList(
                     p("The Time Trends page allows you to explore changes in indicators and subindicators 
                        over time stratified by demographics and social determinants of health. This 
                        facilitates comparison across subgroups to determine if care gaps have changed 
                        over time at your clinic."),
                     p("The first plot shows the cumulative percentage of a given indicator over 
                        time each group within a demographic group. The cumulative plot helps users 
                        identify gaps, or the closing of gaps, over time, by group. For example, 
                        if the indicator is 'Assessed' the demographic group is age, the plot 
                        will show the total percentage ever assessed for each age group over time. 
                        The denominator in this case would be the total number of people in that 
                        age group. Note that this reflects the first date when an event occurred."),
                     p("The second plot shows the discrete percent of a given indicator over time 
                        within a demographic group. The discrete plot helps users identify if 
                        efforts to close gaps are having an impact – for example, if a gap in 
                        percent assessed is identified among women, the discrete plot can highlight 
                        whether increased efforts to specifically conduct outreach to women is 
                        resulting in a greater percent in women assessed at discrete time periods. 
                        The discrete plot measures change in the indicator during a specific time period."),
                     p("To create the Time Trends plots, users will make the following selections:"),
                     tags$ul(
                        tags$li('Indicator: Select the indicator to display in the plots (e.g., Assessed).'),
                        tags$li('Comparison variable: Select the demographic or social determinant of health 
                                 category to compare/stratify by. Select the option "none" to see the 
                                 time trend at your site without any stratification.'),
                        tags$li('Range of dates: Select the start and end of the data range you wish to examine. 
                                 This will focus the plot (i.e. "zoom in") on the date ranges of interest. 
                                 Please note that the date range selection will NOT limit the data 
                                 included to only those date ranges. The denominator for the time trends 
                                 plots will include all patients in the data template. Users can 
                                 limit which data are included in the plot by selecting 
                                 "Select active year(s) of client". For most use cases, we 
                                 recommend checking the box for only the current year; this 
                                 limits the data analysis to only those clients who are active 
                                 clients at your clinic (whose process and health outcomes your 
                                 clinic still has the ability to impact).'),
                        tags$li('Time period length: Select the discrete unit of time to 
                                aggregate data - monthly (1 month), quarterly (3 months) 
                                or biannually (6 months).'),
                        tags$li('Filter by second variable: Opens the filtering options.
                                 This allows users to filter the data to only include clients 
                                 belonging to specific groups within a demographic or social 
                                 determinant of health category. For example, if the comparison 
                                 variable is age, users can additionally filter by ethnicity.'),
                        tags$li('Filter variable: The demographic or social determinant of health category
                                 you are interested in filtering on.'),
                        tags$li('Select the groups you want to see: Select the groups you want to be included 
                                in the time trends plots. This will filter the data to only include clients belonging 
                                to the selected groups. If no groups are selected, then all clients will be included.')
                      ),
                     p('Note that the month indicated on the horizontal axis represents the first 
                        month of the relevant time period. For example, if 3 months is chosen as 
                        the time period length, then "January" would represent the entire period 
                        from January through March, and "July" would represent July through September.'),
                     p('An important note about which data are included in Time Trends Plots:'),
                     p('Across both Time Trends plots, the default denominator is all clients 
                        ever seen at your clinic (i.e., all unique clients included in the data 
                        template) in a given demographic/social determinant of health group. Users 
                        can limit which data are included in the plot by selecting “Select active 
                        year(s) of client”. For most use cases, we recommend checking the box for 
                        only the current year; this limits the data analysis to only those clients 
                        who are active clients at your clinic (whose process and health outcomes 
                        your clinic still has the ability to impact).  See the section on "Select 
                        Dashboard Preferences" in the Toolkit for more details on how to limit 
                        analyses to clients seen during specific time periods.')
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
