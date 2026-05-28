
time_trend_server <- function(input, output, tbl, session){
  
  total_events_data <- reactive({
    req(input$time_indicator, input$time_demo_group)
    
    demo_group <- sym(input$time_demo_group)

    if (input$assessed_choice == "Yes"){
      prescribed_lag <- "Interested & Eligible"
    } else {
      prescribed_lag <- "PWH"
    }

    cols_to_select <- switch(
      input$time_indicator,
      "Assessed" = tbl() |> 
        select(contains("icab_rpv") & (contains("counsel") | contains("screen")) & contains("date")) |>
        names(),
      "Counseled" = tbl() |> 
        select(contains("icab_rpv") & contains("counsel") & contains("date")) |>
        names(),
      "Interested" = tbl() |> 
        select(contains("icab_rpv") & contains("counsel")) |>
        names(),
      "Screened" = tbl() |> 
        select(contains("icab_rpv") & contains("screen") & contains("date")) |>
        names(),
      "Eligible" = tbl() |> 
        select(contains("icab_rpv") & contains("screen")) |>
        names(),
      "Prescribed" = "icab_rpv_rx_date", # may want to also select shot 1?
      "Initiated" = "icab_rpv_shot1_date", # may want to select more shots...
      # May want something for sustained as well..
      character(0)
    )
    temp <- tbl() |>
      select(all_of(cols_to_select)) 

    temp

  })
  
  output$time_trend_out1 <- renderDataTable(total_events_data() |> head())
}
