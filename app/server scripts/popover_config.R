# Popover Details Configuration
# This file contains the lookup table and helper function for rendering 
# "Details" buttons with custom popovers next to download buttons.
#
# Structure:
#   - `details_lookup`: tibble mapping section_id to title and description text
#   - `create_details_button()`: helper function to render Details button with popover

# ============================================================================
# Details Lookup Table
# ============================================================================
# Instructions for adding entries:
# - section_id: matches the output$* ID from main_page_server.R
# - details_title: short, clear title for the popover
# - details_text: 1-3 sentence description of what the visualization shows
#
# Entries with "[USER TO FILL]" are placeholders ready for your descriptions.

details_lookup <- tribble(
  ~section_id,              ~details_title,                        ~details_text,
  # ========== Demographics Section ==========
  "sex1",                  "Sex Demographics",                     "[USER TO FILL]",
  "insurance1",            "HIV Medication Payor",                 "[USER TO FILL]",
  "keypop1",               "Key Population Demographics",          "[USER TO FILL]",
  "zip_map_1",              "Zip Code Map",                        "[USER TO FILL]",
  
  # ========== Demographics by LAI ART Section ==========
  "sex1b",                 "Sex Demographics (by LAI use)",            "[USER TO FILL]",
  "race1b",                "Race Demographics (by LAI use)",           "[USER TO FILL]",
  "ethnicity1b",           "Ethnicity (by LAI use)",                   "[USER TO FILL]",
  "age1b",                 "Age Demographics (by LAI use)",            "[USER TO FILL]",
  "insurance1b",           "HIV Medication Payor (by LAI use)",        "[USER TO FILL]",
  "keypop1b",              "Key Population Demographics (by LAI use)", "[USER TO FILL]",
  "zip_map_1b",             "Zip Code Map (by LAI use)",               "[USER TO FILL]",
  
  # ========== LAI Care Gap Analysis ==========
  "lai_care_gap",          "Care Gap Analysis",             "[USER TO FILL]",
  "assessed_outcomes",     "Assessed Outcomes",             "[USER TO FILL]",
  
  # ========== Assessed Section ==========
  "assessed_overall",      "Assessed Overall",                     "[USER TO FILL]",
  "sex2",                  "Assessed by Sex",                      "[USER TO FILL]",
  "race2",                 "Assessed by Race",                     "[USER TO FILL]",
  "ethnicity2",            "Assessed by Ethnicity",                "[USER TO FILL]",
  "age2",                  "Assessed by Age",                      "[USER TO FILL]",
  "insurance2",            "Assessed by HIV Medication Payor",     "[USER TO FILL]",
  "keypop2",               "Assessed by Key Population",           "[USER TO FILL]",
  "time2",                 "Assessed Over Time (by person)",       "[USER TO FILL]",
  "time2_event",           "Assessed Over Time (by encounter)",    "[USER TO FILL]",
  
  # ========== Counseled Section ==========
  "counseled_overall",     "Counseled Overall",                    "[USER TO FILL]",
  "sex3",                  "Counseled by Sex",                     "[USER TO FILL]",
  "race3",                 "Counseled by Race",                    "[USER TO FILL]",
  "ethnicity3",            "Counseled by Ethnicity",               "[USER TO FILL]",
  "age3",                  "Counseled by Age",                     "[USER TO FILL]",
  "insurance3",            "Counseled by HIV Medication Payor",    "[USER TO FILL]",
  "keypop3",               "Counseled by Key Population",          "[USER TO FILL]",
  "time3",                 "Counseled Over Time (by person)",      "[USER TO FILL]",
  "time3_event",           "Counseled Over Time (by encounter)",   "[USER TO FILL]",
  
  # ========== Interested Section ==========
  "interested_overall",    "Interested Overall",                       "[USER TO FILL]",
  "sex4",                  "Interested by Sex",                        "[USER TO FILL]",
  "race4",                 "Interested by Race",                       "[USER TO FILL]",
  "ethnicity4",            "Interested by Ethnicity",                  "[USER TO FILL]",
  "age4",                  "Interested by Age",                        "[USER TO FILL]",
  "insurance4",            "Interested by HIV Medication Payor",       "[USER TO FILL]",
  "keypop4",               "Interested by Key Population",             "[USER TO FILL]",
  "time4",                 "Interested Over Time (by person)",         "[USER TO FILL]",
  "time4_event",           "Interested Over Time (by encounter)",      "[USER TO FILL]",
  "not_interested_reason", "Reasons Not Interested",                   "[USER TO FILL]",
  
  # ========== Screened Section ==========
  "screened_overall",      "Screened Overall",                         "[USER TO FILL]",
  "sex5",                  "Screened by Sex",                          "[USER TO FILL]",
  "race5",                 "Screened by Race",                         "[USER TO FILL]",
  "ethnicity5",            "Screened by Ethnicity",                    "[USER TO FILL]",
  "age5",                  "Screened by Age",                          "[USER TO FILL]",
  "insurance5",            "Screened by HIV Medication Payor",         "[USER TO FILL]",
  "keypop5",               "Screened by Key Population",               "[USER TO FILL]",
  "time5",                 "Screened Over Time (by person)",           "[USER TO FILL]",
  "time5_event",           "Screened Over Time (by encounter)",        "[USER TO FILL]",
  
  # ========== Eligible Section ==========
  "eligible_overall",      "Eligible Overall",                         "[USER TO FILL]",
  "sex6",                  "Eligible by Sex",                          "[USER TO FILL]",
  "race6",                 "Eligible by Race",                         "[USER TO FILL]",
  "ethnicity6",            "Eligible by Ethnicity",                    "[USER TO FILL]",
  "age6",                  "Eligible by Age",                          "[USER TO FILL]",
  "insurance6",            "Eligible by HIV Medication Payor",         "[USER TO FILL]",
  "keypop6",               "Eligible by Key Population",               "[USER TO FILL]",
  "time6",                 "Eligible Over Time (by person)",           "[USER TO FILL]",
  "time6_event",           "Eligible Over Time (by encounter)",        "[USER TO FILL]",
  "not_eligible_reason",   "Reasons Not Eligible",                     "[USER TO FILL]",
  
  # ========== Prescribed Section ==========
  "prescribed_overall",    "Prescribed Overall",                       "[USER TO FILL]",
  "sex7",                  "Prescribed by Sex",                        "[USER TO FILL]",
  "race7",                 "Prescribed by Race",                       "[USER TO FILL]",
  "ethnicity7",            "Prescribed by Ethnicity",                  "[USER TO FILL]",
  "age7",                  "Prescribed by Age",                        "[USER TO FILL]",
  "insurance7",            "Prescribed by HIV Medication Payor",       "[USER TO FILL]",
  "keypop7",               "Prescribed by Key Population",             "[USER TO FILL]",
  "time7",                 "Prescribed Over Time",                     "[USER TO FILL]",
  
  # ========== Accessible Section ==========
  "accessible_overall",    "Accessible Overall",                       "[USER TO FILL]",
  "sex7a",                 "Accessible by Sex",                        "[USER TO FILL]",
  "race7a",                "Accessible by Race",                       "[USER TO FILL]",
  "ethnicity7a",           "Accessible by Ethnicity",                  "[USER TO FILL]",
  "age7a",                 "Accessible by Age",                        "[USER TO FILL]",
  "insurance7a",           "Accessible by HIV Medication Payor",       "[USER TO FILL]",
  "keypop7a",              "Accessible by Key Population",             "[USER TO FILL]",
  "time7a",                "Accessible Over Time",                     "[USER TO FILL]",
  "not_accessible_reason", "Reasons Not Accessible",                   "[USER TO FILL]",
  
  # ========== Initiated Section ==========
  "initiated_overall",     "Initiated Overall",                        "[USER TO FILL]",
  "sex8",                  "Initiated by Sex",                         "[USER TO FILL]",
  "race8",                 "Initiated by Race",                        "[USER TO FILL]",
  "ethnicity8",            "Initiated by Ethnicity",                   "[USER TO FILL]",
  "age8",                  "Initiated by Age",                         "[USER TO FILL]",
  "insurance8",            "Initiated by HIV Medication Payor",        "[USER TO FILL]",
  "keypop8",               "Initiated by Key Population",              "[USER TO FILL]",
  "time8",                 "Initiated Over Time",                      "[USER TO FILL]",
  
  # ========== Sustained Section ==========
  "sustained_overall",     "Sustained Overall",                        "[USER TO FILL]",
  "sex9",                  "Sustained by Sex",                         "[USER TO FILL]",
  "race9",                 "Sustained by Race",                        "[USER TO FILL]",
  "ethnicity9",            "Sustained by Ethnicity",                   "[USER TO FILL]",
  "age9",                  "Sustained by Age",                         "[USER TO FILL]",
  "insurance9",            "Sustained by HIV Medication Payor",        "[USER TO FILL]",
  "keypop9",               "Sustained by Key Population",              "[USER TO FILL]",
  "time9",                 "Time Spent on iCAB/RPV",                   "[USER TO FILL]",
  "discontinued_reason",   "Reasons Discontinued",                     "[USER TO FILL]",
  
  # ========== Clinical Outcomes Section ==========
  "ontime_status",         "On Time Injections",                       "[USER TO FILL]",
  "ontime_monthly",        "On Time by Days Since Prior (Monthly)",    "[USER TO FILL]",
  "ontime_bimonthly",      "On Time by Days Since Prior (Bimonthly)",  "[USER TO FILL]",
  "late_pt",               "Late Injections by Client",                "[USER TO FILL]",
  "early_pt",              "Early Injections by Client",               "[USER TO FILL]",
  
  # ========== Viral Load Section ==========
  "vl_time_to_vs",         "Time to Viral Suppression",                "[USER TO FILL]",
  "time_to_el_vl1",        "Time to Elevated VL",                      "[USER TO FILL]",
  "time_to_el_vl2",        "Time to Elevated VL (Alternative)",        "[USER TO FILL]",
  "time_to_failure1",      "Time to Treatment Failure",                "[USER TO FILL]",
  "time_to_failure2",      "Time to Treatment Failure (Alternative)",  "[USER TO FILL]",
  "clinic_level_vl",       "Clinic Level Viral Load",                  "[USER TO FILL]"
) |>
  mutate(
    page = case_when(
      str_detect(section_id, "lai_care_gap|assessed_outcomes") ~ "lai_overview",
      str_detect(section_id, "vl") ~ "vl_page",
      str_detect(section_id, "failure") ~ "vl_page",
      str_detect(section_id, "ontime") ~ "inj_page",
      str_detect(section_id, "_pt") ~ "inj_page",
      str_detect(section_id, "1$") ~ "demographics_page",
      str_detect(section_id, "1b$") ~ "demo_by_lai",
      str_detect(section_id, "2$|assessed|2_event") ~ "Assessed",
      str_detect(section_id, "3$|counseled|3_event") ~ "Counseled",
      str_detect(section_id, "4$|interested|4_event") ~ "Interested",
      str_detect(section_id, "5$|screened|5_event") ~ "Screened",
      str_detect(section_id, "6$|eligible|6_event") ~ "Eligible",
      str_detect(section_id, "7$|prescribed") ~ "Prescribed",
      str_detect(section_id, "7a$|accessible") ~ "Accessible",
      str_detect(section_id, "8$|initiated") ~ "Initiated",
      str_detect(section_id, "9$|sustained|discontinued") ~ "Sustained",
    ),
    group_name = case_when(
      str_detect(section_id, "sex") ~ "Sex",
      str_detect(section_id, "race") ~ "Race",
      str_detect(section_id, "ethnicity") ~ "Ethnicity",
      str_detect(section_id, "age") ~ "Age",
      str_detect(section_id, "insurance") ~ "HIV Medication Payor",
      str_detect(section_id, "keypop") ~ "Key Population"
  )
)

# ============================================================================
# Helper Function: create_details_button
# ============================================================================
#' Create a Details Button with Popover
#'
#' @param section_id Character. The section identifier to look up in details_lookup.
#'
#' @return A tagList containing an actionButton and a conditionalPanel with
#'         the matching title and text, or NULL if section_id not found.
#'
#' @details
#' The button is styled as a small secondary action button with a circle-info icon.
#' Clicking the button toggles a simple details panel below it.
#' If the section_id is not found in the lookup table, silently returns NULL.
create_details_button <- function(section_id) {
  lookup <- details_lookup |>
    filter(section_id == !!section_id)
  
  if (nrow(lookup) == 0) {
    return(NULL)
  }
  
  title <- lookup$details_title[1]
  text <- lookup$details_text[1]
  button_id <- paste0(section_id, "_details_btn")
  panel_id <- paste0(section_id, "_details_panel")
  
  # Use a div with relative positioning to contain the absolutely positioned popover
  div(
    style = "position: relative; display: inline-block;",
    tagList(
      actionButton(
        inputId = button_id,
        label = "Details",
        icon = icon("circle-info"),
        class = "details-toggle-btn"
      ),
      conditionalPanel(
        condition = sprintf("input.%s %% 2 == 1", button_id),
        div(
          # Absolute positioning for the popover box, centered
          style = "position: absolute; z-index: 1000; margin-top: 10px; left: 50%; transform: translateX(-50%); width: 40vw;",
          box(
            id = panel_id,
            class = "details-panel",
            title = div(
              class = "details-title-wrap", style = "font-size: 15px;",
              strong(title),
              tags$button(
                type = "button",
                class = "details-close-btn",
                `aria-label` = "Close details",
                HTML("&times;"),
                onclick = sprintf("$('#%s').trigger('click');", button_id)
              )
            ),
            status = "info",
            solidHeader = TRUE,
            width = 12,
            div(
              class = "box-body",
              tags$span(style = "font-size: 14px;", HTML(str_replace_all(text, "\n", "<br>")))
            )
          )
        )
      )
    )
  )
}
