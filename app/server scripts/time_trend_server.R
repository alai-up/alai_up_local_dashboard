
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

    base_size <- 14 
    text_size <- base_size / 2.5

    temp <- tbl() |>
      select(alai_up_uid, !!demo_group, all_of(cols_to_select)) |>
      pivot_longer(cols = -c(alai_up_uid,!!demo_group),
                   names_to = c("event",".value"),
                   names_pattern = "(.+)_(date|outcome)",
                   values_drop_na = TRUE)
    
    if ("outcome" %in% names(temp)){
      temp <- temp |>
        mutate(outcome = case_when(
        input$time_indicator == "Interested" & outcome == "1" ~ "0", # not interested
        input$time_indicator == "Interested" & outcome == "3" ~ "1", # interested
        input$time_indicator == "Interested" & outcome == "2" ~ "2", # maybe interested
        .default = outcome
      )) 
    }

    temp <- temp |>
      mutate(.by = alai_up_uid,
             first_date = min(date,na.rm = T),
             last_date = max(date,na.rm = T),
             first_date = data.table::fifelse(first_date == Inf, NA, first_date),
             last_date = data.table::fifelse(last_date == -Inf, NA, last_date)) |>
      filter(.by = alai_up_uid,
             date == first_date) |>
      select(-event,-date) |>
      distinct() |>
      mutate(period = floor_date(first_date,unit = "months")) 

    if (input$time_indicator %in% c("Assessed","Counseled","Screened","Prescribed","Initiated")){
      p <- temp |>
        group_by(period,!!demo_group) |>
        count() |>
        ungroup() |>
        drop_na() |>
        ggplot(aes(x = period, y = n, fill = !!demo_group)) +
        geom_bar(position = "dodge", stat = "identity") + 
        labs(x = NULL, y = NULL)
      
    } else {
      p <- temp |>
        group_by(period, !!demo_group, outcome) |>
        count() |>
        ungroup() |>
        drop_na() |>
        filter(outcome == 1) |>
        ggplot(aes(x = period, y = n, fill = !!demo_group)) +
        geom_bar(position = "dodge", stat = "identity") + 
        labs(x = NULL, y = NULL) 
      
    }

    p

  })
  
  output$time_trend_monthly <- renderPlot(total_events_data())
}
