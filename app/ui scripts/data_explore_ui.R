
list(
  fluidRow(
    column(width=12,
           box(id = "de_info_box",
                   title = "Instructions",
                   width = 12,
                   status = "info",
                   solidHeader = TRUE,
                   tagList(
                     p("The data explorer allows you to dive deeper into your data, 
                        by showing LAI ART indicators across two variables at once."),
                     p('There are 4 inputs you can modify.'),
                     tags$ul(
                       tags$li("Indicator: First, select an indicator of interest 
                                from the dropdown list (e.g., counseled)."),
                       tags$li("Comparison variable: Second, select a comparison variable 
                                (e.g., race). This will display stratified bars for each 
                                category of that comparison variable (e.g., American Indian 
                                or Alaskan Native, Asian, Black, Native Hawaiian or 
                                Pacific Islander, White, Other)."),
                       tags$li("Filter variable: Third, select a filter variable 
                                (e.g., age). This will allow you to select specific 
                                groups within that variable to filter the data 
                                (e.g., only focus on the group ages 24-34 years).")
                     ),
                     p("For example, suppose you are interested in comparing the 
                        percentage counseled across race categories for PWH aged 
                        25-34. You would (1) select 'Counseled' as the indicator; 
                        (2) select 'Race' as the comparison variable; and (3) 
                        select 'Age' as the filter variable, and check off only 
                        the '25-34' age group. The resulting plot would show you 
                        the number and percentage counseled by race for those 
                        aged 25-34, allowing for simple comparison between the 
                        groups. In other words, this plot answers the question: 
                          among clients ages 25-34 (filter variable), what 
                        percent have been counseled about LAI ART (indicator), 
                        by race category (comparison variable)."),
                     p("If 'Demographics' is selected as the indicator, the 
                        bars will show the distribution of the comparison 
                        variable among the group selected via the filter 
                        variable. For example, if 'Age' is the comparison 
                        variable and 'Sex' is the filter variable, you 
                        will see the age distribution by sex."),
                     p("If you are interested in focusing on an active year of 
                       clients, check the 'Filter clients by active year' box
                       to expand those options.")
                   )
               )
           )
  ),
  fluidRow(
    box(title = "Crosstab data",
        width = 12,
        status = "primary", solidHeader = T,
        plotOutput("data_explore_plot"),
        downloadButton(outputId = "data_explore_plot_download", label = "Download plot"),
        downloadButton(outputId = "data_explore_table_download",  
                       label = "Download table",
                       icon = icon("table")),
        size = "xs"
  )
)
)
