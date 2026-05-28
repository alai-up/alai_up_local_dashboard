
time_trend_server <- function(input, output, ic_df, session){

  total_events_data <- reactive({
    req(input$time_indicator, input$time_demo_group)
    
    demo_group <- sym(input$time_demo_group)

    cols_to_select <- switch(
      input$time_indicator,
      "Assessed" = ic_df() |> 
        select(contains("icab_rpv") & (contains("counsel") | contains("screen")) & contains("date")) |>
        names(),
      "Counseled" = ic_df() |> 
        select(contains("icab_rpv") & contains("counsel") & contains("date")) |>
        names(),
      "Interested" = ic_df() |> 
        select(contains("icab_rpv") & contains("counsel")) |>
        names(),
      "Screened" = ic_df() |> 
        select(contains("icab_rpv") & contains("screen") & contains("date")) |>
        names(),
      "Eligible" = ic_df() |> 
        select(contains("icab_rpv") & contains("screen")) |>
        names(),
      "Prescribed" = "icab_rpv_rx_date", # may want to also select shot 1?
      "Initiated" = "icab_rpv_shot1_date", # may want to select more shots...
      # May want something for sustained as well..
      character(0)
    )

    base_size <- 14 
    text_size <- base_size / 2.5

    # get denominators
    denom_df <- ic_df() |>
      summarize(.by = !!demo_group,
                denominator = case_when(
                    input$time_indicator %in% c("Assessed","Counseled","Screened") ~ sum(PWH,na.rm = TRUE),
                    input$time_indicator == "Interested" ~ sum(Counseled,na.rm = TRUE),
                    input$time_indicator == "Eligible" ~ sum(Screened,na.rm = TRUE),
                    input$time_indicator == "Prescribed" & input$assessed_choice == "Yes" ~ sum(`Interested & Eligible`,na.rm = TRUE),
                    input$time_indicator == "Prescribed" & input$assessed_choice == "No" ~ sum(PWH,na.rm = TRUE),
                    input$time_indicator == "Initiated" ~ sum(Prescribed,na.rm = TRUE),
                    .default = sum(PWH, na.rm = TRUE)
                ))

    temp <- ic_df() |>
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
      temp <- temp |>
        group_by(period,!!demo_group) |>
        count() |>
        ungroup() |>
        drop_na()

    } else {
      temp <- temp |>
        group_by(period, !!demo_group, outcome) |>
        count() |>
        ungroup() |>
        drop_na() |>
        filter(outcome == 1)
    }

    # TODO complete period by group so that everyone has 0's in numerator
    # filter out 0's in denominator though (via join maybe)
    out_df <- temp |>
      full_join(denom_df, by = join_by(!!demo_group)) |>
      mutate(pct = n/denominator) 
      
    return(out_df)

  })


  output$time_trend_total <- renderPlot({
    
    demo_group <- sym(input$time_demo_group)
    
    total_events_data() |>
      arrange(!!demo_group, period) |>
      mutate(.by = !!demo_group,
             total = cumsum(n),
             total_pct = total/denominator) |>
      ggplot(aes(x = period, y = total_pct, color = !!demo_group)) + 
      geom_line()
  })
  
  output$time_trend_monthly <- renderPlot({

    demo_group <- sym(input$time_demo_group)

    total_events_data() |>
      ggplot(aes(x = period, y = pct, fill = !!demo_group)) +
      geom_bar(position = "dodge", stat = "identity") + 
      labs(x = NULL, y = NULL) 
  })
}
