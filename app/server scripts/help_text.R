help_text <- list(
  info1 = tagList(
    p("This page shows overall clinic demographics and client characteristics, 
      for all people with HIV served at your clinic, regardless of LAI ART use."),
    p("Use the Jump to Section navigator on the near left to jump to different
      sections of this page.")
  ),
  info1b = tagList(
    p("This page shows overall clinic demographics and client characteristics, 
      for all people with HIV served at your clinic, stratified by LAI ART use."),
    p("Use the Jump to Section navigator on the near left to jump to different
      sections of this page.")
  ),
  
  info0 = tagList(
    p("This page provides an overview of the LAI ART care gap analysis. It also includes 
      details about the documented counseling and screening outcomes for those assessed."),
    tags$ul(   
      tags$li('"Assessed" is a combined indicator representing the number of 
              PWH with documented counseling or screening for iCAB/RPV.'),
      tags$li('"Interested & Eligible" indicates the number of PWH who were assessed 
              to be both interested and eligible for iCAB/RPV.'),
      tags$li('"Prescribed" indicates the number of PWH who were prescribed 
              iCAB/RPV.'),
      tags$li('"Initiated" indicates the number of PWH who received at least 
              one injection of iCAB/RPV among those prescribed.'),
      tags$li('"Sustained" indicates the number of PWH who were currently 
              sustained on iCAB/RPV at the site among those initiated.')
    ),
    p('The "Outcomes among those assessed" table shows the distribution of counseling 
      and screening outcomes among those assessed. The "Percent" buttons allow you to
      change how the percentages are calculated: "Table" for using the number assessed
      as the denominator, "Row" for using the row total, and "Column" for using the
      column total. For example, to see the percentage eligible among those interested, 
      using the row percent is best. The highlighted cell shows the number of people who are interested and
      eligible, as in the LAI ART care gap analysis.'),
    p('Use the Jump to Section navigator on the near left to jump to different 
      sections of this page.'),
    p("To view details about each LAI ART care indicator, click the corresponding tab
      on the main sidebar on the left.")
  ),
  
  info2 = tagList(
    p('This page shows the number and percentage of people with HIV at the site
      who were assessed. "Assessed" is a combined indicator
      representing the number of PWH with documented counseling or screening for iCAB/RPV.'),
    p("To view details about the number of clients counseled, screened, 
      interested, and eligible for iCAB/RPV, you can navigate to those pages by clicking on 
      the corresponding tabs on the left."),
    p('Light gray bars show indicators with fewer than 10 clients and therefore
      should be interpreted with caution, given the sample size. The dotted line
      shows the average for that indicator across all clinic clients.')
  ),
  
  info3 = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      who were counseled about iCAB/RPV."),
    p("To view details about the number of clients interested in iCAB/RPV following 
      counseling, you can navigate to the corresponding tab on the left.")
  ),
  
  info4 = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      interested in iCAB/RPV among those counseled. There is
      also a plot showing reasons for not being interested in iCAB/RPV.")
  ),
  
  info5 = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      screened for eligibility for iCAB/RPV.")
  ),
  
  info6 = tagList(
    p("This page shows the number and percentage of people with HIV at the site 
      who were assessed to be eligible for iCAB/RPV based on site-specific 
      eligibility criteria. It also includes a plot showing reasons
      for not being eligible for iCAB/RPV.")
  ),
  
  info7 = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      who were prescribed iCAB/RPV. The percentage is calculated
      among those interested and eligible (if counseling and screening 
      are consistently recorded) or among all PWH
      at the clinic (if counseling and screening are not consistently recorded).")
  ),

  info7a = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      who could financially access iCAB/RPV after being prescribed. 
      The percentage is calculated among those prescribed. 
      It also includes a plot showing reasons that iCAB/RPV was not financially accessible
      to clients who were prescribed.")
  ),
  
  info8 = tagList(
    p("This page shows the number and percentage of people with HIV at the site
      who received at least one injection of iCAB/RPV among those prescribed.")
  ),
  
  info9 = tagList(
    p("This page shows the number and percentage of people with HIV at the site 
      currently sustained on iCAB/RPV at the site among those initiated. 
      There is also a plot showing time spent on iCAB/RPV and reasons for discontinuation.")
  ),
  
  info10 = tagList(
    p("This page shows the numbers and percentages of early, on time, and late 
      injections out of all follow-up injections after the first injection. 'Early' 
      is defined as occurring more than seven days before the target injection 
      date. 'Late' is defined as occurring more than seven days after the target
      injection date. The target injection date can be toggled on the left, 
      depending on the site's clinical practice. Either 28 or 56 days (4 or 8 weeks),
      or 31 or 62 days (1 or 2 months) may be used to calculate the target interval."),
    p('"On time injections" shows the overall percentage of injections administered early, on time, and late.'),
    p('"On time injections by days since prior injection" shows how early or late particular injections were, 
        with the on time injection region shaded in gray There is a plot for monthly injection intervals and
        a plot for bimonthly injection intervals.'),
    p('"Late injections by client" shows how many clients had how many late injections.'),
    p('"Early injections by client" shows how many clients had how many early injections.')
  ),
  
  info11 = tagList(
    p('This page shows viral load results among clients on iCAB/RPV. Different 
      viral load cutoffs of interest can be selected on the left. Either 50 copies/mL 
      or 200 copies/mL can be used to calculate viral suppression. Viral failure 
      is defined as a single viral load >1000 copies/mL or 2 consecutive viral loads
      >200 copies/mL.'),
    p('The first 5 plots are calculated using the Kaplan-Meier estimator. This gives a statistical
      estimate of the time to the first occurrence of the event. Therefore, the percentages
      are only statistical estimates and have some uncertainty attached to them. The
      number of people contributing data (in parentheses) can give a sense of how certain
      or uncertain the estimate is.'),
    p('For the first plot, ideally the time to viral suppression will be short and reach 
      near 100%. For the subsequent plots, ideally time to first elevated viral load 
      or first viral failure will be long, and the percentage will remain low.'),
    p('For the clinic-level viral load, the percentage of people with a viral load above/below
      the chosen threshold in each time period is shown. The time periods can be every 3 months,
      every 6 months, or every 12 months. It is stratified by iCAB/RPV receipt in period. 
      Note that, while each person can only contribute 1 viral load result during each period, 
      that does not mean that each person appears in every period. In fact, the population of
      people in each period can vary widely; it solely depends on who received a viral load 
      test during that period. This metric should be considered preliminary; interpret these data
      with some caution.')
  )
  
)
