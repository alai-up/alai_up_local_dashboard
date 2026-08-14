
options(dplyr.summarise.inform = FALSE)
options(shiny.maxRequestSize = 30 * 1024^2)
theme_set(theme_minimal())
font_add(family = "Roboto", regular = "Roboto-Regular.ttf", bold = "Roboto-Bold.ttf")
showtext_auto()
showtext_opts(dpi = 96)

source("server scripts/main_page_server.R")
source("server scripts/data_explore_server.R")
source("server scripts/time_trend_server.R")
source("server scripts/server_util.R")
source("server scripts/render_scroll_page.R")
source("server scripts/help_text.R")
source("server scripts/popover_config.R")

# RENDER filter_select UI
dynamic_filter_select <- function(input, output, ic_summary_df,selected_site, session){

  # Create a reactive expression for the filter options
  filter_options <- reactive({
    req(ic_summary_df, input$filter_var)

    grouping_var <- sym(input$grouping_var)
    filter_var <- sym(input$filter_var)

    temp <- ic_summary_df() |>
      group_by(Variable,!!grouping_var,!!filter_var) |>
      summarize(Value = sum(Value), PWH1 = sum(PWH1)) |>
      arrange(match(Variable,c('PWH', 'Assessed','Counseled',
                               'Interested', 'Screened', 'Eligible',
                               'Interested & Eligible',
                               'Prescribed', 'Initiated', 'Sustained',
                               'Accessible'
                              ))) |>
      # this should be the grouping var (first) and filter var (second)
      group_by(!!grouping_var,!!filter_var) |>
      mutate(prev_lab = case_when(Variable == "PWH" ~ "PWH",
                                  Variable == "Counseled" ~ "PWH",
                                  Variable == "Interested" ~ "Counseled",
                                  Variable == "Screened" ~ "PWH",
                                  Variable == "Eligible" ~ "Screened",
                                  Variable == "Interested & Eligible" ~ "Assessed",
                                  Variable == "Accessible" ~ "Prescribed",
                                  .default =  lag(Variable)),
             prev = Value[match(prev_lab, Variable)]) |>
      mutate(Percent=if_else(prev == 0, NA, Value/prev)) |>
      ungroup() |>
      # indicator selection here as a filter
      filter(Variable == if_else(input$indicator != "Demographics",input$indicator,"PWH"),
             prev > 0)

    temp |> pull(!!filter_var) |>
      unique() |>
      as.character() |>
      sort()
  })

  # Render the checkbox group input
  output$filter_select <- renderUI({
    req(input$file1)
    req(filter_options())

    checkboxGroupInput("filter_select",
                       "Select the groups you want to see",
                       choices = filter_options(),
                       selected = filter_options()[1])
  })
}

server <- function(input, output, session) {

  observeEvent(input$file1, {
    file_path <- input$file1$datapath

    # Get all sheet names from the uploaded Excel file
    sheet_names <- excel_sheets(file_path)

    # Dynamically update the 'select_sheet' input with the found names
    updateSelectInput(session,
                      inputId = "select_sheet",
                      choices = sheet_names,
                      selected = sheet_names[1] # Automatically select the first sheet
    )
  })

  observe({
    file_ready <- !is.null(input$file1)
    name_ready <- !is.null(input$site_name_input) && input$site_name_input != ""
    if (file_ready && name_ready){
      enable("go_button")
    } else {
      disable("go_button")
    }
  })

  # loading in the master dataset and processing it
  raw_data <- eventReactive(input$go_button, {
    req(input$file1,input$select_sheet)

     withProgress(message = "Initial Processing", detail = "Reading Excel file...", value = 0.3, {
       result <- tryCatch({
         data <- read_excel(input$file1$datapath,
                            sheet = input$select_sheet,
                            col_types = "text",
                            na = c("NA","UNK", ".", "C","888888","999999"))
        
         incProgress(0.3, detail = "Loading and processing data...")
         data <- load_and_process_data(data)
  
         data
       
       }, error = function(e) {
         showNotification(
           paste("Error processing data. Please check your data carefully.\n
                 The R error message was:", conditionMessage(e)),
           type = "error",
           duration = 10,
           id = "processing_error" # Prevents duplicate notifications
           )
  
         return(NULL)
       })
     })

    req(result)
    return(result)

  })

  output$home_page <-  renderUI({
    source(file='ui scripts/home.R', local= T)$value
  })


  interval_1 <- reactive({
    if (input$ontime_target_input == "4 or 8 weeks") {
      28
    } else if (input$ontime_target_input == "1 or 2 months") {
      31
    }
  })

  interval_2 <- reactive({
    if (input$ontime_target_input == "4 or 8 weeks") {
      56
    } else if (input$ontime_target_input == "1 or 2 months") {
      62
    }
  })

  site_list <- reactive({
    req(input$file1,input$select_sheet)

    raw_data() |>
      pull(site) |>
      unique() |>
      str_sort()
  })

  output$site_choice <- renderUI({
    req(input$file1,input$select_sheet)
    req(length(site_list()) > 1)
    choice_list <- c(str_c(input$site_name_input, " (all sites)"),site_list())

    freezeReactiveValue(input, "site_choice_input")

    selectInput("site_choice_input", "Choose one of the sites below:",
                choices = choice_list,
                selected = choice_list[1])

  })

  trigger_site_filter <- reactiveVal(FALSE)

  observe({
    req(raw_data())
    if (is.null(input$site_choice_input) ||
        !input$site_choice_input %in% site_list()) {
      trigger_site_filter(FALSE)
    } else if (input$site_choice_input %in% site_list()){
      trigger_site_filter(TRUE)
    }
  })

  df <- reactive({
    req(raw_data())
    if (trigger_site_filter() == FALSE) {
      return(raw_data())
    } else if (trigger_site_filter() == TRUE){
      return(raw_data() |>
        filter(site == input$site_choice_input))
    }
  })

  # Track the substantive filtering state to prevent reactive ping-ponging
  current_filter_state <- reactiveVal(list(active = FALSE, years = NULL))
  
  observe({
    is_filtering <- isTRUE(input$filter_by_year) && length(input$active_year) > 0
    
    # If they want filtering but the UI hasn't provided the year input yet, wait
    if (is_filtering && is.null(input$active_year)) {
      return()
    }
    
    new_state <- list(
      active = is_filtering,
      years = if (is_filtering) input$active_year else NULL
    )
    
    # Only push an update to trigger the pipeline if the SEMANTIC state actually changed
    if (!identical(current_filter_state(), new_state)) {
      current_filter_state(new_state)
    }
  })

  tbl <- reactive({
    req(df())
    state <- current_filter_state()
    
    if (state$active) {
      req(state$years)
      return(filter_active_year(df(), state$years))
    } else {
      return(df())
    }
  }) |>
    bindEvent(df(), current_filter_state(), ignoreNULL = TRUE)

  cab_master_df <- reactive({
    req(tbl(), interval_1(), interval_2())
    
    prepare_cab_master_df(tbl(), interval_1(), interval_2())

  })

  ic_summary_df <- reactive({
    req(tbl())
    
    prepare_ic_summary(tbl())

  })

  ic_df <- reactive({
    req(tbl())
    
    get_IC_df(tbl())

  })

  pipeline_status <- reactive({
  req(df())
  
  withProgress(message = "Processing data",
               detail = "Preparing data...",
               value = 0.2,
               {
                 # Step 1: Filter data
                 incProgress(0.2, detail = "Filtering...")
                 tbl_data <- tbl()
                 
                 # Step 2: Prepare CAB data
                 incProgress(0.2, detail = "Computing iCAB/RPV metrics...")
                 cab_data <- cab_master_df()
                 
                 # Step 3: Prepare IC data
                 incProgress(0.2, detail = "Computing summaries...")
                 ic_data <- ic_summary_df()
                 
                 # Step 4: Create IC df
                 incProgress(0.2, detail = "Finalizing...")
                 ic_final <- ic_df()
                 
                 list(tbl = tbl_data, cab = cab_data, ic_summary = ic_data, ic = ic_final)
               })
  })
  
  observe({
    pipeline_status()
  })

  active_year_options <- reactive({
    req(df())
    df() |>
      select(contains("active") & where(~!all(is.na(.)))) |>
      names() |>
      str_extract("\\d+") |>
      as.numeric() |>
      sort()
  })

  # Calculate site once as a reactive to pass to modules
  selected_site_reactive <- reactive({
    req(site_list())
    if (length(site_list()) > 1) input$site_choice_input else input$site_name_input
  })

  # Initialize modules ONCE at top-level. 
  # Pass the reactive objects (e.g., tbl, NOT tbl()) so they manage their own invalidation.
  main_page_server(input, output, tbl, ic_df, ic_summary_df, selected_site_reactive, cab_master_df, interval_1, interval_2, session)
  dynamic_filter_select(input, output, ic_summary_df, selected_site_reactive, session)
  data_explore_server(input, output, ic_summary_df, session)
  time_trend_server(input, output, ic_df, session)

  observe({
    
    req(tbl(), ic_summary_df(), cab_master_df(), ic_df())

      updateActionButton(session, "go_button",
                         label = "Data are ready",
                         icon = icon("check"))
  })

  full_report_data <- reactive({
    req(tbl(), ic_summary_df(), cab_master_df())
    full_report_table(ic_summary_df(), cab_master_df())
  })

  output$full_report_download <- download_table("ALAI_UP_Report",full_report_data())

  output$full_report_download_ui <- renderUI({
    req(ic_summary_df())

    downloadButton("full_report_download", "Download Results",
                   style = "color: #333; background-color: #f4f4f4; border-color: #ccc;
                            margin-left: 20px; display: inline-block;")
  })


  output$filter_by_year_ui <- renderUI({
    req(input$file1)
    checkboxInput('filter_by_year',label = "Filter clients by active year",value = FALSE)
  })

  output$active_year_choice <- renderUI({
    req(active_year_options())

    # defensive check if active year options is empty for some reason
    if (length(active_year_options()) == 0){
      year_choices <- as.character(year(Sys.Date()))
    } else {
      year_choices <- as.character(active_year_options())
    }

    checkboxGroupInput(
      inputId = "active_year",
      label = "Select active year(s) of clients:",
      choices = year_choices,
      selected =  year_choices[length(year_choices)]
    )
  }) 


  observeEvent(input$sidebarItemExpanded, {
    if (input$sidebarItemExpanded == "<strong>LAIARTindicators</strong>") {
      updateTabItems(session, inputId = "sidebar", selected = "lai_overview")
    }
    if (input$sidebarItemExpanded == "<strong>ClinicDemographics</strong>") {
      updateTabItems(session, inputId = "sidebar", selected = "demographics_page")
    }
    if (input$sidebarItemExpanded == "<strong>Clinicaloutcomes</strong>") {
      updateTabItems(session, inputId = "sidebar", selected = "inj_page")
    }
  })

  # Define the items and their properties in a simple list
  menu_items <- list(
    list(id = "assessed",  label = strong("Assessed"),              tab = "assessed_page",   ic = NULL),
    list(id = "counseled",  label = "Counseled",                      tab = "counseled_page",   ic = "angle-double-right"),
    list(id = "interested",label = HTML("&nbsp;&nbsp;Interested"), tab = "interested_page", ic = "angle-double-right"),
    list(id = "screened",  label = "Screened",                      tab = "screened_page",   ic = "angle-double-right"),
    list(id = "eligible",  label = HTML("&nbsp;&nbsp;Eligible"),   tab = "eligible_page",   ic = "angle-double-right")
  )
  
  # Use a loop to create the conditionally visible menu items
  map(menu_items, function(item) {
    output[[paste0(item$id, "_sidebar")]] <- renderMenu({
  
      req(input$assessed_choice == "Yes") # Stops rendering if choice is not "Yes"
  
      menuItem(
        text = item$label,
        tabName = item$tab,
        icon = if(!is.null(item$ic)) icon(item$ic) else NULL
      )
    })
  })
  
  # Always render the "Accessible" menu item
  output$accessible_sidebar <- renderMenu({
    menuItem(
      text = HTML("Accessible"),
      tabName = "accessible_page",
      icon = icon("angle-double-right")
    )
  })

  observeEvent(input$assessed_choice, {
    if (input$assessed_choice == "No") {
      # If they are on any of the 'Assessed' related tabs, kick them back to home
      if (input$sidebar %in% c('assessed_page', 'counseled_page', 'interested_page', 'screened_page', 'eligible_page', 'accessible_page')) {
        updateTabItems(session, "sidebar", "lai_overview")
      }
    }
  })

  # Time trends page
  output$time_indicator <- renderUI({
    req(input$file1)
    if (input$assessed_choice == "Yes"){
      choice_list <- c("Assessed",
                       'Counseled',
                       'Interested',
                       'Screened',
                       "Eligible",
                       "Prescribed",
                       "Accessible",
                       "Initiated",
                       "Sustained")
    } else {
      choice_list <- c("Prescribed",
                       "Accessible",
                       "Initiated",
                       "Sustained")
    }
    selectInput("time_indicator",
                "Select an indicator",
                choices = choice_list,
                selected = choice_list[1])
  })

  output$time_demo_group <- renderUI({
    req(input$file1)
    choice_list <- c("None" = "none",
                     "Age" = "age_cat",
                     "Sex" = "sex",
                     "Race" = "race",
                     "Ethnicity" = "ethnicity",
                     "HIV medication payor" = "insurance_status",
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
                     "SDOH Other 3" = "SDOH_other_3")

    if (length(site_list()) > 1){
      choice_list <- c(choice_list,c("Site" = "site"))
    }

    selectInput("time_demo_group",
                "Comparison variable",
                choices = choice_list,
                selected = "age_cat")
  })

  output$time_demo_group_2 <- renderUI({
    # select from the groups not chosen in output$time_demo_group
    req(input$file1)
    choice_list <- c("Age" = "age_cat",
                     "Sex" = "sex",
                     "Race" = "race",
                     "Ethnicity" = "ethnicity",
                     "HIV medication payor" = "insurance_status",
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
                     "SDOH Other 3" = "SDOH_other_3")

    if (length(site_list()) > 1){
      choice_list <- c(choice_list,c("Site" = "site"))
    }

    choice_list <- choice_list[choice_list != input$time_demo_group]

    selectInput("time_demo_group_2",
                "Filter variable",
                choices = choice_list,
                selected = choice_list[1])
  })

  output$time_demo_group_2_selection <- renderUI({
    # get the list of options from the relevant demographic group selected in output$time_demo_group_2
    req(input$time_demo_group_2)
    grouping_var <- sym(input$time_demo_group_2)
    temp <- ic_df() |>
      group_by(!!grouping_var) |>
      summarize(PWH = sum(PWH)) |>
      arrange(!!grouping_var)

    choice_list <- temp |> pull(!!grouping_var) |> as.character() |> sort()

    checkboxGroupInput("time_demo_group_2_selection",
                       "Select the groups you want to see",
                       choices = choice_list,
                       selected = choice_list[1])

  })
  
  output$time_trends_page <- renderUI({
    req(input$file1)
    source(file='ui scripts/time_trend_ui.R', local= T)$value

  })

  
  # Data explore page
  output$indicator <- renderUI({
    req(input$file1)
    if (input$assessed_choice == "Yes"){
      choice_list <- c("Demographics",
                       "Assessed",
                       'Counseled',
                       'Interested',
                       'Screened',
                       "Eligible",
                       "Interested & Eligible",
                       "Prescribed",
                       "Accessible",
                       "Initiated",
                       "Sustained")
    } else {
      choice_list <- c("Demographics",
                       "Prescribed",   
                       "Accessible",
                       "Initiated",
                       "Sustained")
    }
    selectInput("indicator",
                "Select an indicator",
                choices = choice_list,
                selected = "Demographics")
  })

  # RENDER grouping_var UI
  output$grouping_var <- renderUI({
    req(input$file1)
    choice_list <- c("Age" = "age_cat",
                     "Sex" = "sex",
                     "Race" = "race",
                     "Ethnicity" = "ethnicity",
                     "HIV medication payor" = "insurance_status",
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
                      "SDOH Other 3" = "SDOH_other_3")

    if (length(site_list()) > 1){
      choice_list <- c(choice_list,c("Site" = "site"))
    }

    selectInput("grouping_var",
                "Comparison variable",
                choices = choice_list,
                selected = "age_cat")
  })

  # OBSERVE changes to grouping_var and update filter_var
  observeEvent(input$grouping_var, {
    all_vars <-  c("Age" = "age_cat",
                   "Sex" = "sex",
                   "Race" = "race",
                   "Ethnicity" = "ethnicity",
                   "HIV medication payor" = "insurance_status",
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
                    "SDOH Other 3" = "SDOH_other_3")

    if (length(site_list()) > 1){
      all_vars <- c(all_vars,c("Site" = "site"))
    }

    other_vars <- all_vars[all_vars != input$grouping_var]

    updateSelectInput(session, "filter_var",
                      choices = other_vars,
                      selected = other_vars[[1]])
  })

  # RENDER filter_var UI
  output$filter_var_ui <- renderUI({
    req(input$file1)
    req(input$grouping_var)  # depends on this being ready
    selectInput("filter_var", "Filter by", choices = NULL)
  })

  output$data_explore_page <- renderUI({
    req(input$file1)
    req(input$grouping_var)
    req(input$filter_var)
    req(input$filter_select)
    source(file='ui scripts/data_explore_ui.R', local= T)$value

  })

  # main pages
  # action links for scrolling
  demo_sections_info <- list(
    list(id = "top1", title = "Home", plot = NULL, download = NULL),
    list(id = "sex1", title = "Sex", plot = "sex1_plot", download = "sex1_download_ui"),
    list(id = "race1", title = "Race", plot = "race1_plot", download = "race1_download_ui"),
    list(id = "ethnicity1", title = "Ethnicity", plot = "ethnicity1_plot", download = "ethnicity1_download_ui"),
    list(id = "age1", title = "Age", plot = "age1_plot", download = "age1_download_ui"),
    list(id = "insurance1", title = "HIV medication payor", plot = "insurance1_plot", download = "insurance1_download_ui"),
    list(id = "keypop1", title = "Key populations", plot = NULL, download = NULL),
    list(id = "zip1", title = "ZIP code", plot = NULL, download = NULL)
  )

  output$demographics_page <- renderUI({
    req(input$file1)

    choice_list <- c("Housing status",
                     "Risk MSM","Risk IDU","Risk Heterosex",
                     "Employment status","Poverty level",
                     "Immigration status","Language",
                     "Incarceration history","Recent CD4",
                     "SDOH Other 1","SDOH Other 2","SDOH Other 3")

    if (length(site_list()) > 1){
      choice_list <- c(choice_list,"Site")
    }

    fluidPage(
      fluidRow(
        column(
          width = 2,
          div(class = "toc-container",
              h4("Jump to Section"),
              div(class = "toc-links",
                  map(demo_sections_info, function(section) {
                    actionLink(inputId = paste0("go_", section$id), label = section$title)
                  })
              )
          )
        ),
        column(
          width = 10,
          # Special treatment for "Home"/top-level content
          div(id = "top1", h3(uiOutput("overall_n"), style = "font-size: 26px;")),
          box(id = "info1_box",
              title = "Instructions",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              help_text$info1),
          # Plot boxes
          map(demo_sections_info[2:6], function(section) {
            box(
              id = paste0(section$id, "_box"),
              title = section$title,
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              plotOutput(section$plot, height = "auto"),
              uiOutput(section$download),
              size = "xs"
            )
          }),
          #box for key pop
          box(id = "keypop1_box",
              title = "Key Populations",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              selectInput(
                inputId = "keypop1_choice",
                label = "Key population choice",
                choices = choice_list,
                selected = "Housing status"),
              plotOutput("keypop1_plot",, height = "auto"),
              div(style = "padding: 10px; color: #B22222; font-size: 12px;",
                  'Select the key population/social determinant of health you are interested in looking at. If data are missing from a particular column, those rows will appear as "unknown".'),
              uiOutput("keypop1_download_ui")),
          # Box for the map
          box(id = "zip1_box",
              title = "ZIP codes",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              actionButton("render_map_button",
                           label = "Create map",
                           icon = icon("play")),
              leafletOutput("zip_map"),
              div(style = "padding: 10px; color: #B22222; font-size: 12px;",
                  "Note: Use caution when sharing this map, as small cell sizes may risk client confidentiality."),
              tagList(downloadButton(outputId = "map_data_download", label = "Download data")),
                      create_details_button("zip_map_1"))
        )
      )
    )
  })

  map(demo_sections_info, function(section) {
    observeEvent(input[[paste0("go_", section$id)]], {
      runjs(sprintf("
      const target = document.getElementById('%s_box') || document.getElementById('%s');
      if (target) {
        window.scrollTo({
          top: target.getBoundingClientRect().top + window.scrollY - 120,
          behavior: 'smooth'
        });
      }
    ", section$id, section$id))
    })
  })

# demographics by LAI ART ART page
  demo_sections_info_b <- list(
    list(id = "top1b", title = "Home", plot = NULL, download = NULL),
    list(id = "sex1b", title = "Sex", plot = "sex1b_plot", download = "sex1b_download_ui"),
    list(id = "race1b", title = "Race", plot = "race1b_plot", download = "race1b_download_ui"),
    list(id = "ethnicity1b", title = "Ethnicity", plot = "ethnicity1b_plot", download = "ethnicity1b_download_ui"),
    list(id = "age1b", title = "Age", plot = "age1b_plot", download = "age1b_download_ui"),
    list(id = "insurance1b", title = "HIV medication payor", plot = "insurance1b_plot", download = "insurance1b_download_ui"),
    list(id = "keypop1b", title = "Key populations", plot = NULL, download = NULL),
    list(id = "zip1b", title = "ZIP code", plot = NULL, download = NULL)
  )

  output$demo_by_lai <- renderUI({
    req(input$file1)

    choice_list <- c("Housing status",
                     "Risk MSM","Risk IDU","Risk Heterosex",
                     "Employment status","Poverty level",
                     "Immigration status","Language",
                     "Incarceration history","Recent CD4",
                     "SDOH Other 1","SDOH Other 2","SDOH Other 3")

    if (length(site_list()) > 1){
      choice_list <- c(choice_list,"Site")
    }

    fluidPage(
      fluidRow(
        column(
          width = 2,
          div(class = "toc-container",
              h4("Jump to Section"),
              div(class = "toc-links",
                  map(demo_sections_info_b, function(section) {
                    actionLink(inputId = paste0("go_", section$id), label = section$title)
                  })
              )
          )
        ),
        column(
          width = 10,
          # Special treatment for "Home"/top-level content
          div(id = "top1", h3(uiOutput("overall_n"), style = "font-size: 26px;")),
          box(id = "info1b_box",
              title = "Instructions",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              help_text$info1b),
          # Plot boxes
          map(demo_sections_info_b[2:6], function(section) {
            box(
              id = paste0(section$id, "_box"),
              title = section$title,
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              plotOutput(section$plot, height = "auto"),
              uiOutput(section$download),
              size = "xs"
            )
          }),
          box(id = "keypop1b_box",
              title = "Key Populations",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              selectInput(
                inputId = "keypop1b_choice",
                label = "Key population choice",
                choices = choice_list,
                selected = "Housing status"),
              plotOutput("keypop1b_plot",, height = "auto"),
              div(style = "padding: 10px; color: #B22222; font-size: 12px;",
                  'Select the key population/social determinant of health you are interested in looking at. If data are missing from a particular column, those rows will appear as "unknown".'),
              uiOutput("keypop1b_download_ui")),
          # Box for the map
          box(id = "zip1b_box",
              title = "ZIP codes",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              actionButton("render_map_button_b",
                           label = "Create map",
                           icon = icon("play")),
              leafletOutput("zip_map_b"),
              div(style = "padding: 10px; color: #B22222; font-size: 12px;",
                  "Note: Use caution when sharing this map, as small cell sizes may risk client confidentiality."),
              tagList(downloadButton(outputId = "map_data_b_download", label = "Download data")),
                      create_details_button("zip_map_1b"))
        )
      )
    )
  })

  map(demo_sections_info_b, function(section) {
    observeEvent(input[[paste0("go_", section$id)]], {
      runjs(sprintf("
      const target = document.getElementById('%s_box') || document.getElementById('%s');
      if (target) {
        window.scrollTo({
          top: target.getBoundingClientRect().top + window.scrollY - 120,
          behavior: 'smooth'
        });
      }
    ", section$id, section$id))
    })
  })

  lai_overview_sections <- reactive({
    sections <- list(
      list(id = "top0",title = "Home",plot = NULL, download = NULL),
      list(id = "care_gap", title = "LAI ART Care Gap Analysis", plot = "lai_care_gap_plot",
           download = "lai_care_gap_download_ui")
    )

    if (input$assessed_choice == "Yes"){
      sections <- append(sections, list(

        list(id = "assessed_outcomes", title = "Outcomes among those assessed", plot = NULL,
             download = NULL)
      ))
    }
    return(sections)
  })

  output$lai_overview <- renderUI({
    req(input$file1)

    if (input$assessed_choice == "Yes"){
      int_elig_box <- box(id = "assessed_outcomes_box",
                          title = "Outcomes among those assessed",
                          width = 12,
                          status = "primary",
                          solidHeader = TRUE,
                          div(style = "display:flex; align-items:top; gap:10px;",
                              div("Percent"),
                              radioButtons(
                                inputId = "int_elig_pct",label = NULL,
                                choices = c("Table", "Row", "Column"),
                                selected = "Table",
                                inline = TRUE)),
                          gt_output(outputId = "int_elig_table"),
                          downloadButton(outputId = "int_elig_table_download",
                                         label = "Download table",
                                         icon = icon("table")),
                          create_details_button("assessed_outcomes"),
                          size = "xs")
    } else {
      int_elig_box <- NULL
    }

    fluidPage(
      fluidRow(
        column(
          width = 2,
          div(class = "toc-container",
              h4("Jump to Section"),
              div(class = "toc-links",
                  map(lai_overview_sections(), function(section) {
                    actionLink(inputId = paste0("go_", section$id), label = section$title)
                  })
              )
          )
        ),
        column(
          width = 10,
          # Special treatment for "Home"/top-level content
          div(id = "top0", h3(uiOutput("overall_n"), style = "font-size: 26px;")),
          box(id = "info0_box",
              title = "Instructions",
              width = 12,
              status = "info",
              solidHeader = TRUE,
              help_text$info0),
          # Plot boxes
          map(lai_overview_sections()[2], function(section) {
            box(
              id = paste0(section$id, "_box"),
              title = section$title,
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              plotOutput(section$plot, height = "auto"),
              uiOutput(section$download),
              size = "xs"
            )
          }),
          int_elig_box
        )
      )
    )
  })

  observe({
    map(lai_overview_sections(), function(section) {
      local({
        observeEvent(input[[paste0("go_", section$id)]], {
          runjs(sprintf("
      const target = document.getElementById('%s_box') || document.getElementById('%s');
      if (target) {
        window.scrollTo({
          top: target.getBoundingClientRect().top + window.scrollY - 120,
          behavior: 'smooth'
        });
      }
    ", section$id, section$id))
        })
      })
    })
  })


  keypop_choice_list <- reactive({
    temp <- c("Housing status",
      "Risk MSM","Risk IDU","Risk Heterosex",
      "Employment status","Poverty level",
      "Immigration status","Language",
      "Incarceration history","Recent CD4",
      "SDOH Other 1","SDOH Other 2","SDOH Other 3")

    if (length(site_list()) > 1){
      temp <- c(temp,"Site")
    }

    return(temp)
  })

  assessed_sections_info <- list(
    list(id = "top2", title = "Home", plot = NULL, download = NULL),
    list(id = "overall2", title = "Overall", plot = "assessed_overall_plot", download = "assessed_overall_download_ui"                 ),
    list(id = "sex2", title = "Sex", plot = "sex2_plot", download = "sex2_download_ui"                                                 ),
    list(id = "race2", title = "Race", plot = "race2_plot", download = "race2_download_ui"                                             ),
    list(id = "ethnicity2", title = "Ethnicity", plot = "ethnicity2_plot", download = "ethnicity2_download_ui"                         ),
    list(id = "age2", title = "Age", plot = "age2_plot", download = "age2_download_ui"                                                 ),
    list(id = "insurance2", title = "HIV medication payor", plot = "insurance2_plot", download = "insurance2_download_ui"                  ),
    list(id = "keypop2", title = "Key populations", plot = "keypop2_plot", download = "keypop2_download_ui"                            ),
    list(id = "time2", title = "Assessed over time by person", plot = "time2_plot", download = "time2_download_ui"                     ),
    list(id = "time2_event", title = "Assessed over time by encounter", plot = "time2_event_plot", download = "time2_event_download_ui")
  )

  # Assessed
  renderSectionPage(
    input, output,
    page_id = "assessed_page",
    sections_info = assessed_sections_info,
    n_output_id = "assessed_n"
  )

  observe({
    updateSelectInput(session, "keypop2_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop2_choice) # Preserve user selection
  })

  counseled_sections_info <- list(
    list(id = "top3", title = "Home", plot = NULL, download = NULL),
    list(id = "overall3", title = "Overall", plot = "counseled_overall_plot", download = "counseled_overall_download_ui"),
    list(id = "sex3", title = "Sex", plot = "sex3_plot", download = "sex3_download_ui"),
    list(id = "race3", title = "Race", plot = "race3_plot", download = "race3_download_ui"),
    list(id = "ethnicity3", title = "Ethnicity", plot = "ethnicity3_plot", download = "ethnicity3_download_ui"),
    list(id = "age3", title = "Age", plot = "age3_plot", download = "age3_download_ui"),
    list(id = "insurance3", title = "HIV medication payor", plot = "insurance3_plot", download = "insurance3_download_ui"),
    list(id = "keypop3", title = "Key populations", plot = "keypop3_plot", download = "keypop3_download_ui"),
    list(id = "time3", title = "Counseled over time by person", plot = "time3_plot", download = "time3_download_ui"),
    list(id = "time3_event", title = "Counseled over time by encounter", plot = "time3_event_plot", download = "time3_event_download_ui")
  )



  # Counseled
  renderSectionPage(
    input, output,
    page_id = "counseled_page",
    sections_info = counseled_sections_info,
    n_output_id = "counseled_n"
  )

  observe({
    updateSelectInput(session, "keypop3_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop3_choice)
  })

  interested_sections_info <- list(
    list(id = "top4", title = "Home", plot = NULL, download = NULL),
    list(id = "overall4", title = "Overall", plot = "interested_overall_plot", download = "interested_overall_download_ui"),
    list(id = "sex4", title = "Sex", plot = "sex4_plot", download = "sex4_download_ui"),
    list(id = "race4", title = "Race", plot = "race4_plot", download = "race4_download_ui"),
    list(id = "ethnicity4", title = "Ethnicity", plot = "ethnicity4_plot", download = "ethnicity4_download_ui"),
    list(id = "age4", title = "Age", plot = "age4_plot", download = "age4_download_ui"),
    list(id = "insurance4", title = "HIV medication payor", plot = "insurance4_plot", download = "insurance4_download_ui"),
    list(id = "keypop4", title = "Key populations", plot = "keypop4_plot", download = "keypop4_download_ui"),
    list(id = "time4", title = "Interested over time by person", plot = "time4_plot", download = "time4_download_ui"),
    list(id = "time4_event", title = "Interested over time by encounter", plot = "time4_event_plot", download = "time4_event_download_ui"),
    list(id = "reason4", title = "Not interested reasons", plot = "not_interested_reason_plot", download = "not_interested_reason_download_ui")
  )

  # interested
  renderSectionPage(
    input, output,
    page_id = "interested_page",
    sections_info = interested_sections_info,
    n_output_id = "interested_n"
  )

  observe({
    updateSelectInput(session, "keypop4_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop4_choice)
  })

  screened_sections_info <- list(
    list(id = "top5", title = "Home", plot = NULL, download = NULL),
    list(id = "overall5", title = "Overall", plot = "screened_overall_plot", download = "screened_overall_download_ui"),
    list(id = "sex5", title = "Sex", plot = "sex5_plot", download = "sex5_download_ui"),
    list(id = "race5", title = "Race", plot = "race5_plot", download = "race5_download_ui"),
    list(id = "ethnicity5", title = "Ethnicity", plot = "ethnicity5_plot", download = "ethnicity5_download_ui"),
    list(id = "age5", title = "Age", plot = "age5_plot", download = "age5_download_ui"),
    list(id = "insurance5", title = "HIV medication payor", plot = "insurance5_plot", download = "insurance5_download_ui"),
    list(id = "keypop5", title = "Key populations", plot = "keypop5_plot", download = "keypop5_download_ui"),
    list(id = "time5", title = "Screened over time by person", plot = "time5_plot", download = "time5_download_ui"),
    list(id = "time5_event", title = "Screened over time by encounter", plot = "time5_event_plot", download = "time5_event_download_ui")
 )

  # screened
  renderSectionPage(
    input, output,
    page_id = "screened_page",
    sections_info = screened_sections_info,
    n_output_id = "screened_n"
  )

  observe({
    updateSelectInput(session, "keypop5_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop5_choice)
  })

  eligible_sections_info <- list(
    list(id = "top6", title = "Home", plot = NULL, download = NULL),
    list(id = "overall6", title = "Overall", plot = "eligible_overall_plot", download = "eligible_overall_download_ui"),
    list(id = "sex6", title = "Sex", plot = "sex6_plot", download = "sex6_download_ui"),
    list(id = "race6", title = "Race", plot = "race6_plot", download = "race6_download_ui"),
    list(id = "ethnicity6", title = "Ethnicity", plot = "ethnicity6_plot", download = "ethnicity6_download_ui"),
    list(id = "age6", title = "Age", plot = "age6_plot", download = "age6_download_ui"),
    list(id = "insurance6", title = "HIV medication payor", plot = "insurance6_plot", download = "insurance6_download_ui"),
    list(id = "keypop6", title = "Key populations", plot = "keypop6_plot", download = "keypop6_download_ui"),
    list(id = "time6", title = "Eligible over time by person", plot = "time6_plot", download = "time6_download_ui"),
    list(id = "time6_event", title = "Eligible over time by encounter", plot = "time6_event_plot", download = "time6_event_download_ui"),
    list(id = "reason6", title = "Not eligible reasons", plot = "not_eligible_reason_plot", download = "not_eligible_reason_download_ui")
  )

  # eligible
  renderSectionPage(
    input, output,
    page_id = "eligible_page",
    sections_info = eligible_sections_info,
    n_output_id = "eligible_n"
  )

  observe({
    updateSelectInput(session, "keypop6_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop6_choice)
  })

  prescribed_sections_info <- list(
    list(id = "top7", title = "Home", plot = NULL, download = NULL),
    list(id = "overall7", title = "Overall", plot = "prescribed_overall_plot", download = "prescribed_overall_download_ui"),
    list(id = "sex7", title = "Sex", plot = "sex7_plot", download = "sex7_download_ui"),
    list(id = "race7", title = "Race", plot = "race7_plot", download = "race7_download_ui"),
    list(id = "ethnicity7", title = "Ethnicity", plot = "ethnicity7_plot", download = "ethnicity7_download_ui"),
    list(id = "age7", title = "Age", plot = "age7_plot", download = "age7_download_ui"),
    list(id = "insurance7", title = "HIV medication payor", plot = "insurance7_plot", download = "insurance7_download_ui"),
    list(id = "keypop7", title = "Key populations", plot = "keypop7_plot", download = "keypop7_download_ui"),
    list(id = "time7", title = "Prescribed over time", plot = "time7_plot", download = "time7_download_ui")
 )

  # prescribed
  renderSectionPage(
    input, output,
    page_id = "prescribed_page",
    sections_info = prescribed_sections_info,
    n_output_id = "prescribed_n"
  )

  observe({
    updateSelectInput(session, "keypop7_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop7_choice)
  })

  accessible_sections_info <- list(
    list(id = "top7a", title = "Home", plot = NULL, download = NULL),
    list(id = "overall7a", title = "Overall", plot = "accessible_overall_plot", download = "accessible_overall_download_ui"),
    list(id = "sex7a", title = "Sex", plot = "sex7a_plot", download = "sex7a_download_ui"),
    list(id = "race7a", title = "Race", plot = "race7a_plot", download = "race7a_download_ui"),
    list(id = "ethnicity7a", title = "Ethnicity", plot = "ethnicity7a_plot", download = "ethnicity7a_download_ui"),
    list(id = "age7a", title = "Age", plot = "age7a_plot", download = "age7a_download_ui"),
    list(id = "insurance7a", title = "HIV medication payor", plot = "insurance7a_plot", download = "insurance7a_download_ui"),
    list(id = "keypop7a", title = "Key populations", plot = "keypop7a_plot", download = "keypop7a_download_ui"),
    list(id = "time7a", title = "Accessible over time", plot = "time7a_plot", download = "time7a_download_ui"),
    list(id = "reason7a", title = "Not accessible reasons", plot = "not_accessible_reason_plot", download = "not_accessible_reason_download_ui")
 )

  # accessible
  renderSectionPage(
    input, output,
    page_id = "accessible_page",
    sections_info = accessible_sections_info,
    n_output_id = "accessible_n"
  )

  observe({
    updateSelectInput(session, "keypop7a_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop7a_choice)
  })

  initiated_sections_info <- list(
    list(id = "top8", title = "Home", plot = NULL, download = NULL),
    list(id = "overall8", title = "Overall", plot = "initiated_overall_plot", download = "initiated_overall_download_ui"),
    list(id = "sex8", title = "Sex", plot = "sex8_plot", download = "sex8_download_ui"),
    list(id = "race8", title = "Race", plot = "race8_plot", download = "race8_download_ui"),
    list(id = "ethnicity8", title = "Ethnicity", plot = "ethnicity8_plot", download = "ethnicity8_download_ui"),
    list(id = "age8", title = "Age", plot = "age8_plot", download = "age8_download_ui"),
    list(id = "insurance8", title = "HIV medication payor", plot = "insurance8_plot", download = "insurance8_download_ui"),
    list(id = "keypop8", title = "Key populations", plot = "keypop8_plot", download = "keypop8_download_ui"),
    list(id = "time8", title = "Initiated over time", plot = "time8_plot", download = "time8_download_ui")
  )

  # initiated
  renderSectionPage(
    input, output,
    page_id = "initiated_page",
    sections_info = initiated_sections_info,
    n_output_id = "initiated_n"
  )

  observe({
    updateSelectInput(session, "keypop8_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop8_choice)
  })

  sustained_sections_info <- list(
    list(id = "top9", title = "Home", plot = NULL, download = NULL),
    list(id = "overall9", title = "Overall", plot = "sustained_overall_plot", download = "sustained_overall_download_ui"),
    list(id = "sex9", title = "Sex", plot = "sex9_plot", download = "sex9_download_ui"),
    list(id = "race9", title = "Race", plot = "race9_plot", download = "race9_download_ui"),
    list(id = "ethnicity9", title = "Ethnicity", plot = "ethnicity9_plot", download = "ethnicity9_download_ui"),
    list(id = "age9", title = "Age", plot = "age9_plot", download = "age9_download_ui"),
    list(id = "insurance9", title = "HIV medication payor", plot = "insurance9_plot", download = "insurance9_download_ui"),
    list(id = "keypop9", title = "Key populations", plot = "keypop9_plot", download = "keypop9_download_ui"),
    list(id = "time9", title = "Time spent on iCAB/RPV", plot = "time9_plot", download = "time9_download_ui"),
    list(id = "reason9", title = "Discontinued reasons", plot = "discontinued_reason_plot", download = "discontinued_reason_download_ui")
  )

  # sustained
  renderSectionPage(
    input, output,
    page_id = "sustained_page",
    sections_info = sustained_sections_info,
    n_output_id = "sustained_n"
  )

  observe({
    updateSelectInput(session, "keypop9_choice",
                      choices = keypop_choice_list(),
                      selected = input$keypop9_choice)
  })

  clinical_sections_info <- list(
    list(id = "top10", title = "Home", plot = NULL, download = NULL),
    list(id = "status_bar", title = "On time injections", plot = "ontime_status_bar", download = "ontime_status_download_ui"),
    list(id = "ontime_1m", title = "On time injections by days since prior injection, monthly injection interval", plot = "ontime_plot_monthly", download = "ontime_monthly_download_ui"),
    list(id = "ontime_2m", title = "On time injections by days since prior injection, bimonthly injection interval", plot = "ontime_plot_bimonthly", download = "ontime_bimonthly_download_ui"),
    list(id = "late_pt", title = "Late injections by client", plot = "late_pt_plot", download = "late_pt_download_ui"),
    list(id = "early_pt", title = "Early injections by client", plot = "early_pt_plot", download = "early_pt_download_ui")
  )

  renderSectionPage(
    input, output,
    page_id = "inj_page",
    sections_info = clinical_sections_info,
    n_output_id = "clinical_n"
  )

  val1 <- reactive({
    if (input$vl_cutoff_input == "50 copies/mL"){
      "<50"
    } else if (input$vl_cutoff_input == "200 copies/mL"){
      "<200"
    }
  })

  val2 <- reactive({
    if (input$vl_cutoff_input == "50 copies/mL"){
      "\u226550"
    } else if (input$vl_cutoff_input == "200 copies/mL"){
      "\u2265200"
    }
  })

  # VL page
  vl_sections_info <- vl_sections_info <- reactive({
    list(
      list(id = "top11", title = "Home", plot = NULL, download = NULL),
      list(id = "time_to_vs", title = str_c("Time to first VL ",val1()), plot = "vl_time_to_vs", download = "vl_time_to_vs_download_ui"),
      list(id = "time_to_el_vl1", title = str_c("Time to first VL ",val2()," pre-iCAB/RPV VL ",val1()), plot = "time_to_el_vl1", download = "time_to_el_vl1_download_ui"),
      list(id = "time_to_el_vl2", title = str_c("Time to first VL ",val2()," pre-iCAB/RPV VL ",val2()), plot = "time_to_el_vl2", download = "time_to_el_vl2_download_ui"),
      list(id = "time_to_failure1", title = str_c("Time to first treatment failure, pre-iCAB/RPV VL ",val1()), plot = "time_to_failure1", download = "time_to_failure1_download_ui"),
      list(id = "time_to_failure2", title = str_c("Time to first treatment failure, pre-iCAB/RPV VL ",val2()), plot = "time_to_failure2", download = "time_to_failure2_download_ui"),
      list(id = "clinic_level_vl", title = "Clinic level viral load", plot = "clinic_level_vl", download = "clinic_level_vl_download_ui")
    )
  })

  observe({
    renderSectionPage(
      input, output,
      page_id = "vl_page",
      sections_info = vl_sections_info(),
      n_output_id = "vl_n"
    )
  })

}
