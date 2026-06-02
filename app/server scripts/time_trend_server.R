
time_trend_server <- function(input, output, ic_df, session){

    # Shared constants and helpers -------------------------------------------------
  choice_list <- c(
    "None" = "none",
    "Age" = "age_cat",
    "Sex" = "sex",
    "Race" = "race",
    "Ethnicity" = "ethnicity",
    "Insurance status" = "insurance_status",
    "Housing status" = "housing_status",
    "Risk MSM" = "risk_msm",
    "Risk IDU" = "risk_idu",
    "Risk Heterosex" = "risk_heterosex",
    "Employment status" = "employment_status",
    "Poverty level" = "poverty_level",
    "Immigration status" = "immigration_status_undoc",
    "Language" = "language",
    "Incarceration history" = "incarceration_history",
    "Recent CD4" = "cd4_recent_result",
    "SDOH Other 1" = "SDOH_other_1",
    "SDOH Other 2" = "SDOH_other_2",
    "SDOH Other 3" = "SDOH_other_3",
    "Site" = "site"
  )

  date_breaks_from_range <- function(first_date, last_date){
    date_diff <- as.numeric(difftime(last_date, first_date, units = "days"))
    if (date_diff <= 92) {
      "1 month"
    } else if (date_diff < 365) {
      "3 months"
    } else {
      "6 months"
    }
  }

  finalize_time_plot <- function(p, expand_x = waiver()){
    first_date <- min(p$data$period, na.rm = TRUE)
    last_date  <- max(p$data$period, na.rm = TRUE)
    p +
      theme_minimal(base_family = "Roboto") +
      theme(text = element_text(size = 15), axis.text.x = element_text(size = 15, color = "black")) +
      scale_x_date(date_labels = "%b %Y",
                   expand = expand_x
                  #  date_breaks = date_breaks_from_range(first_date, last_date)
                  )
  }

  get_demo_label <- function(name_key) names(choice_list)[choice_list == name_key]

  # ---------------------------------------------------------------------------
  
  total_events_data <- reactive({
    req(input$time_indicator, input$time_demo_group, ic_df())
    
    demo_group <- sym(input$time_demo_group)
    
    input_df <- ic_df()
    if (input$time_demo_group == "none") {
      input_df <- input_df |> mutate(none = "Overall")
    }

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
      "Prescribed" = ic_df() |> 
        select(contains("icab_rpv_rx_date") | (contains("icab_rpv_shot") & contains("date"))) |>
        names(), 
      "Initiated" = ic_df() |> 
        select(contains("icab_rpv_shot") & contains("date")) |>
        names(), 
      # May want something for sustained as well..
      character(0)
    )

    # get denominators
    denom_df <- input_df |>
      summarize(.by = !!demo_group,
                denominator = sum(PWH, na.rm = TRUE)
                )

    temp <- input_df |>
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
      mutate(period = floor_date(first_date,unit = str_c(input$time_trend_period_time_choice, " months"))) 

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
        group_by(period, !!demo_group) |>
        mutate(monthly_total = sum(n)) |>
        ungroup() |>
        drop_na() |>
        filter(outcome == 1)
    }

    out_df <- temp |>
      complete(period, !!demo_group, fill = list(n = 0)) |>
      full_join(denom_df, by = join_by(!!demo_group)) |>
      filter(.by = !!demo_group, denominator > 0) |>
      bind_rows(bind_rows(
        temp |>
          distinct(!!demo_group) |>
          mutate(
            period = min(temp$period) - months(1),
            n = 0
          )
        )
      )

      
    return(out_df)

  })

  title_df <- reactive({
    temp <- tibble(
      numerator = c("Assessed","Counseled","Screened",
                    "Interested","Eligible","Prescribed",
                    "Initiated"),
    ) |>
      mutate(denominator = "PWH") |>
      expand_grid(plot = c("Total","Monthly")) |>
      mutate(title_string = str_c(plot," percent ", numerator, " out of ", denominator))

  })
  
  output$time_trend_date_filter <- renderUI({
    req(total_events_data())

    min_date <- total_events_data() |>
      pull(period) |>
      min(na.rm = TRUE)

    max_date <- total_events_data() |>
      pull(period) |>
      max(na.rm = TRUE)
    
    sliderInput(
      inputId = 'time_trend_date_filter',
      label = "Range of dates",
      min = min_date,
      max = max_date,
      value = c(min_date,max_date),
      timeFormat = "%b-%Y"
    )
  })

  events_data_filtered <- reactive({
    req(total_events_data(), input$time_trend_date_filter)

    total_events_data() |>
      filter(period >= floor_date(input$time_trend_date_filter[1],unit = str_c(input$time_trend_period_time_choice, " months")),
             period <= floor_date(input$time_trend_date_filter[2],unit = str_c(input$time_trend_period_time_choice, " months")))
  })

  time_trend_total_plot <- reactive({
    validate(need(events_data_filtered(), "Preparing plots..."))
    
    demo_group <- sym(input$time_demo_group)

    p <- events_data_filtered() |>
      arrange(!!demo_group, period) |>
      mutate(.by = !!demo_group,
             total = cumsum(n),
             total_pct = total/denominator) |>
      ggplot(aes(x = period, y = total_pct, color = !!demo_group,
             group = !!demo_group)) + 
      geom_line() +
      ggrepel::geom_text_repel(
        data = \(d) d |>
          filter(.by = !!demo_group, period == max(period)),
        aes(label = !!demo_group),
        nudge_x = 20,
        direction = "y",
        hjust = 0,
        size = 5,
        segment.linetype = "dashed",
        box.padding = 0.6,
        point.padding = 0.4,
        min.segment.length = 0,
        max.overlaps = Inf
      ) + 
      labs(x = NULL, y = NULL,
           title = str_c(
             title_df() |> filter(numerator == input$time_indicator, plot == "Total") |> pull(title_string),
             if (input$time_demo_group == "none") "" else str_c(" by ", get_demo_label(input$time_demo_group))
           )) +
      scale_y_continuous(labels = scales::percent)

    finalize_time_plot(p, expand_x = expansion(mult = c(0.05, 0.1))) + 
      theme(legend.position = "none")

  })

  output$time_trend_total_plot_download <- download_box(paste0(input$time_demo_group,"_time_trend_total"), time_trend_total_plot())
  output$time_trend_total_table_download <- download_table(paste0(input$time_demo_group,"_time_trend_total"), time_trend_total_plot()$data)

  output$time_trend_total <- renderPlot({
    time_trend_total_plot()
  })

  time_trend_monthly_plot <- reactive({
    validate(need(events_data_filtered(), "Preparing plots..."))

    demo_group <- sym(input$time_demo_group)

    p <- events_data_filtered() |>
      mutate(pct = n/denominator) |>
      ggplot(aes(x = period, y = pct, fill = !!demo_group)) +
      geom_bar(position = "dodge", stat = "identity") + 
      scale_y_continuous(labels = scales::percent) + 
      labs(x = NULL, y = NULL,
           fill = if (input$time_demo_group == "none") NULL else get_demo_label(input$time_demo_group),
           title = str_c(
             title_df() |> filter(numerator == input$time_indicator, plot == "Monthly") |> pull(title_string),
             if (input$time_demo_group == "none") "" else str_c(" by ", get_demo_label(input$time_demo_group))
           ))

    p <- finalize_time_plot(p)
    if (input$time_demo_group == "none") {
      p <- p + theme(legend.position = "none")
    }
    p

  })

  output$time_trend_monthly_plot_download <- download_box(paste0(input$time_demo_group,"_time_trend_monthly"), time_trend_monthly_plot())
  output$time_trend_monthly_table_download <- download_table(paste0(input$time_demo_group,"_time_trend_monthly"), time_trend_monthly_plot()$data)

  
  output$time_trend_monthly <- renderPlot({
    time_trend_monthly_plot()
  })
}
