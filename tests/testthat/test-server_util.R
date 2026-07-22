source(test_path("../../app/server scripts/server_util.R"))

test_that("filter_active_year filters data correctly", {
  
  # 1. SETUP: Create a simple dataframe to test against.
  test_df <- tibble::tribble(
    ~alai_up_uid, ~active_2023, ~active_2024,
    "patient_A", 1, 0,
    "patient_B", 0, 1,
    "patient_C", 1, 1
  )
  
  # 2. EXECUTE & ASSERT
  
  # Test case 1: Filtering for a single year
  result_2023 <- filter_active_year(test_df, "2023")
  expect_equal(nrow(result_2023), 2)
  expect_equal(result_2023$alai_up_uid, c("patient_A", "patient_C"))
  
  # Test case 2: Filtering for multiple years (should return patients active in EITHER year)
  result_both <- filter_active_year(test_df, c("2023", "2024"))
  expect_equal(nrow(result_both), 3) # All patients are active in at least one of the years
  
  # Test case 3: What if the input year is NULL? It should return the original dataframe.
  result_null <- filter_active_year(test_df, NULL)
  expect_equal(nrow(result_null), 3)
  expect_identical(result_null, test_df)
  
})

test_that(".get_basic_indicators calculates correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_counsel_ever, ~icab_rpv_screen_ever, ~icab_rpv_rx, ~icab_rpv_shot1_date, ~icab_rpv_shot2_date, ~icab_rpv_discontinued,
    "patient_A", 1, 0, 0, NA, NA, NA, # Counseled only
    "patient_B", 0, 1, 0, NA, NA, NA, # Screened only
    "patient_C", 0, 0, 1, NA, NA, NA, # Prescribed only
    "patient_D", 0, 0, 0, as.Date("2023-01-01"), NA, 0, # Initiated, not discontinued
    "patient_E", 0, 0, 0, as.Date("2023-01-01"), NA, 1, # Initiated, discontinued
    "patient_F", 0, 0, 0, NA, NA, NA, # None
    "patient_G", 1, 1, 1, as.Date("2023-01-01"), as.Date("2023-02-01"), 0 # All
  )
  
  result <- .get_basic_indicators(test_df)
  
  # Expected results
  expected <- tibble::tribble(
    ~alai_up_uid, ~Assessed, ~Counseled, ~Screened, ~Prescribed, ~Initiated, ~Sustained,
    "patient_A", 1, 1, 0, 0, 0, 0,
    "patient_B", 1, 0, 1, 0, 0, 0,
    "patient_C", 1, 1, 1, 1, 0, 0,
    "patient_D", 1, 1, 1, 1, 1, 1,
    "patient_E", 1, 1, 1, 1, 1, 0,
    "patient_F", 0, 0, 0, 0, 0, 0,
    "patient_G", 1, 1, 1, 1, 1, 1
  )
  
  expect_equal(result$Assessed, expected$Assessed)
  expect_equal(result$Counseled, expected$Counseled)
  expect_equal(result$Screened, expected$Screened)
  expect_equal(result$Prescribed, expected$Prescribed)
  expect_equal(result$Initiated, expected$Initiated)
  expect_equal(result$Sustained, expected$Sustained)
  expect_true(all(result$PWH == 1))
  expect_true(all(result$PWH1 == 1))
})

test_that(".get_interested_status works correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_counsel1_outcome, ~icab_rpv_counsel2_outcome,
    "patient_A", 1, 3, # Not interested -> Interested
    "patient_B", 2, 2, # Maybe interested
    "patient_C", 1, 1, # Not interested
    "patient_D", NA, NA # No counseling outcome
  )
  
  result <- .get_interested_status(test_df)
  
  expected <- tibble::tribble(
    ~alai_up_uid, ~Interested,
    "patient_A", 1,
    "patient_B", 2,
    "patient_C", 0,
    "patient_D", NA_real_
  )
  
  expect_equal(result, expected)
})

test_that(".get_eligible_status works correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_screen1_outcome, ~icab_rpv_screen2_outcome,
    "patient_A", 0, 1, # Not eligible -> Eligible
    "patient_B", 0, 0, # Not eligible
    "patient_C", NA, NA # No screening outcome
  )
  
  result <- .get_eligible_status(test_df)
  
  expected <- tibble::tribble(
    ~alai_up_uid, ~Eligible,
    "patient_A", 1,
    "patient_B", 0,
    "patient_C", NA_real_
  )
  
  expect_equal(result, expected)
})

test_that(".get_disinterest_reason works correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_disinterest_reason_1, ~icab_rpv_disinterest_reason_1_other, ~icab_rpv_disinterest_reason_2, ~icab_rpv_disinterest_reason_2_other,
    "patient_A", 1, NA, 20, "Some other reason", # Changes reason, ends with 'other'
    "patient_B", 2, NA, NA, NA, # Single reason
    "patient_C", NA, NA, NA, NA # No reason
  )
  
  expect_warning(result <- .get_disinterest_reason(test_df))
  
  expected <- tibble::tribble(
    ~alai_up_uid, ~disinterest_reason, ~disinterest_other_reason,
    "patient_A", 20, "Some other reason",
    "patient_B", 2, NA_character_,
    "patient_C", NA_real_, NA_character_
  )
  
  expect_equal(result, expected)
})

test_that(".get_not_elig_reason works correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_not_elig_1_reason, ~icab_rpv_not_elig_1_reason_other, ~icab_rpv_not_elig_2_reason, ~icab_rpv_not_elig_2_reason_other,
    "patient_A", "1", NA, "20", "Other eligibility reason", # Changes reason, ends with 'other'
    "patient_B", "2", NA, NA, NA, # Single reason
    "patient_C", NA, NA, NA, NA # No reason
  )
  
  expect_warning(result <- .get_not_elig_reason(test_df))

  expected <- tibble::tribble(
    ~alai_up_uid, ~not_elig_reason, ~not_elig_other_reason,
    "patient_A", "20", "Other eligibility reason",
    "patient_B", "2", NA_character_,
    "patient_C", NA, NA_character_
  )
  
  expect_equal(result, expected)
})

test_that("get_IC_df joins indicators and reasons correctly", {
  test_df <- tibble::tribble(
    ~alai_up_uid, ~icab_rpv_counsel_ever, ~icab_rpv_counsel1_outcome, ~icab_rpv_disinterest_reason_1, 
    ~icab_rpv_disinterest_reason_1_other, ~icab_rpv_screen_ever, ~icab_rpv_screen1_outcome, 
    ~icab_rpv_not_elig_1_reason, ~icab_rpv_not_elig_1_reason_other, 
    ~icab_rpv_rx, ~icab_rpv_shot1_date, ~icab_rpv_shot2_date,
    ~icab_rpv_discontinued,
    # Assessed, Counseled, Not Interested
    "patient_A", 1, 1, 2, NA, 0, NA, NA, NA, 0, NA, NA, NA,
    # Assessed, Screened, Not Eligible
    "patient_B", 0, NA, NA, NA, 1, 0, "3", NA, 0, NA, NA, NA,
    # Assessed, Counseled, Interested, Screened, Eligible, Prescribed, Initiated, Sustained
    "patient_C", 1, 3, NA, NA, 1, 1, NA, NA, 1, as.Date("2023-01-01"), NA,  0,
    # Assessed, Counseled, Interested, Screened, Eligible, but not prescribed
    "patient_D", 1, 3, NA, NA, 1, 1, NA, NA, 0, NA, NA, NA
  )
  
  result <- suppressWarnings(get_IC_df(test_df))

  # Check patient A
  patient_A <- result |> filter(alai_up_uid == "patient_A")
  expect_equal(patient_A$Assessed, 1)
  expect_equal(patient_A$Counseled, 1)
  expect_equal(patient_A$Interested, 0)
  expect_equal(patient_A$disinterest_reason, 2)
  expect_equal(patient_A$Screened, 0)
  expect_true(is.na(patient_A$Eligible))
  expect_equal(patient_A$`Interested & Eligible`, 0)
  
  # Check patient B
  patient_B <- result |> filter(alai_up_uid == "patient_B")
  expect_equal(patient_B$Assessed, 1)
  expect_equal(patient_B$Counseled, 0)
  expect_true(is.na(patient_B$Interested))
  expect_equal(patient_B$Screened, 1)
  expect_equal(patient_B$Eligible, 0)
  expect_equal(patient_B$not_elig_reason, "3")
  expect_equal(patient_B$`Interested & Eligible`, 0)
  
  # Check patient C
  patient_C <- result |> filter(alai_up_uid == "patient_C")
  expect_equal(patient_C$Assessed, 1)
  expect_equal(patient_C$Counseled, 1)
  expect_equal(patient_C$Interested, 1)
  expect_equal(patient_C$Screened, 1)
  expect_equal(patient_C$Eligible, 1)
  expect_equal(patient_C$`Interested & Eligible`, 1)
  expect_equal(patient_C$Prescribed, 1)
  expect_equal(patient_C$Initiated, 1)
  expect_equal(patient_C$Sustained, 1)
  
  # Check patient D
  patient_D <- result |> filter(alai_up_uid == "patient_D")
  expect_equal(patient_D$Interested, 1)
  expect_equal(patient_D$Eligible, 1)
  expect_equal(patient_D$`Interested & Eligible`, 1)
  expect_equal(patient_D$Prescribed, 0)
})
