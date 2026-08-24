help_text <- list(
  info1 = tagList(
    p("This page shows overall clinic demographics and client characteristics for 
    all clients with HIV served at your clinic, regardless of LAI ART use."),
    p("Use the 'Jump to Section' to see plots showing the distribution of the 
    population by sex, race, ethnicity, age, HIV medication payor, and key populations. 
    There is also a heat map that visualizes clients with HIV served at your clinic by ZIP code.")
  ),
  info1b = tagList(
    p("This page shows overall clinic demographics and client characteristics, 
      for all people with HIV served at your clinic, stratified by LAI ART use."),
    p("Use the 'Jump to Section' to see plots showing the distribution of the 
    population by sex, race, ethnicity, age, HIV medication payor, and key populations. 
    There is also a heat map that visualizes clients with HIV who have ever been on an LAI ART served at your clinic by ZIP code.")
  ),
  
  info0 = tagList(
    p("This page provides an overview of the LAI ART care gap analysis. It also includes 
    details about the documented counseling and screening outcomes for those assessed."),
    tags$ul(   
      tags$li('"Assessed" is a combined indicator defined as the proportion of clients 
              counseled about LAI ART or screened for LAI ART clinical eligibility out of 
              clients with HIV served at the clinic within a given time period.'),
      tags$li('"Interested & Eligible" is defined as the proportion of clients interested 
               in and eligible for LAI ART out of clients assessed.'),
      tags$li('"Prescribed" is defined as the proportion of clients prescribed LAI
               ART out of clients interested in and eligible for LAI ART.'),
      tags$li('"Initiated"  is defined as proportion of clients initiated 
               on LAI ART (receiving at least 1 injection) out of clients prescribed LAI ART.'),
      tags$li('"Sustained" is defined as proportion of clients sustained on LAI ART 
               (still receiving LAI ART) out of clients initiated on LAI ART.')
    ),
    p('Use the Jump to Section navigator on the near left to jump to different 
      sections of this page.'),
    p("To view details about each LAI ART care indicator, click the corresponding tab
      on the main sidebar on the left.")
  ),
  
  info2 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic who 
       were assessed for LAI ART. "Assessed" is a combined indicator defined as the 
       proportion of clients counseled about LAI ART or screened for LAI ART clinical 
       eligibility out of clients with HIV served at the clinic within a given time period.'),
    p('There are 9 plots: Overall, by sex, race, ethnicity, age, HIV medication payor, 
      and key populations, assessed over time by person, and assessed over time by encounter.'),
    p('The Overall plot simply shows the percent assessed out of the total clients at the clinic. 
       The plots by sex, race, ethnicity, age, HIV medication payor, and key populations 
       have identical structure. They show the percent assessed out of the total number 
       of clients in each demographic/social determinant group. This enables quick and easy 
       comparisons to understand if there are any differences in assessed by different 
       variables. The dashed line indicates the average, the same value in the Overall 
       plot. Bars above or below the average indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.'),
    p('To view details about the number of clients counseled, screened, interested, 
       and eligible for iCAB/RPV, you can navigate to those pages by clicking on 
       the corresponding tabs on the left.')
  ),
  
  info3 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic who 
       were counseled about LAI ART. "Counseled" is defined as proportion of clients 
       counseled about LAI ART out of the number of clients with HIV served at the clinic 
       within a given time period.'),
    p('There are 9 plots: Overall, by sex, race, ethnicity, age, HIV medication payor, 
       and key populations, counseled over time by person, and counseled over time by encounter.'),
    p('The Overall plot simply shows the percent counseled out of the total clients at 
       the clinic. The plots by sex, race, ethnicity, age, HIV medication payor, and key 
       populations have identical structure. They show the percent counseled out of the total 
       number of clients in each demographic/social determinant group. This enables quick 
       and easy comparisons to understand if there are any differences in counseled by 
       different variables. The dashed line indicates the average, the same value in the 
       Overall plot. Bars above or below the average indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info4 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic who 
       were interested in LAI ART. "Interested" is defined as the proportion of clients 
       interested in LAI ART out of the number of clients counseled about LAI ART within 
       a given time period.'),
    p('There are 10 plots: Overall, by sex, race, ethnicity, age, HIV medication 
       payor, and key populations, interested over time by person, interested over 
       time by encounter, and disinterest reasons.'),
    p('The Overall plot shows the percent interested out of the total clients ever 
       counseled. The plots by sex, race, ethnicity, age, HIV medication payor, and 
       key populations have identical structure. They show the percent interested out 
       of the total number of clients counseled in each demographic/social determinant 
       group. This enables quick and easy comparisons to understand if there are any 
       differences in interested by different variables. The dashed line indicates the 
       average, the same value in the Overall plot. Bars above or below the average 
       indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info5 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic who 
       were screened for eligibility for LAI ART. "Screened" is defined as the proportion 
       of clients screened for eligibility for LAI ART out of the number of clients with 
       HIV served at the clinic within a given time period.'),
    p('There are 9 plots: Overall, by sex, race, ethnicity, age, HIV medication payor, 
       and key populations, screened over time by person, and screened over time by encounter.'),
    p('The Overall plot shows the percent screened out of the total clients with HIV at 
       your clinic. The plots by sex, race, ethnicity, age, HIV medication payor, and key 
       populations have identical structure. They show the percent screened out of the 
       total number of clients in each demographic/social determinant group. This enables 
       quick and easy comparisons to understand if there are any differences in interested 
       by different variables. The dashed line indicates the average, the same value in 
       the Overall plot. Bars above or below the average indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info6 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic who 
       were clinicall eligbile for LAI ART. "Eligible" is defined as the proportion of 
       clients clinically eligible for LAI ART out of the number of clients screened 
       for LAI ART eligibility within a given time period.'),
    p('There are 10 plots: Overall, by sex, race, ethnicity, age, HIV medication 
       payor, and key populations, eligible over time by person, eligible over time 
       by encounter, and not eligible reasons.'),
    p('The Overall plot shows the percent eligible out of the total clients ever 
       screened. The plots by sex, race, ethnicity, age, HIV medication payor, and 
       key populations have identical structure. They show the percent eligible out 
       of the total number of clients screened in each demographic/social determinant 
       group. This enables quick and easy comparisons to understand if there are any 
       differences in eligible by different variables. The dashed line indicates the 
       average, the same value in the Overall plot. Bars above or below the average 
       indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info7 = tagList(
    p('This page shows the number and percentage of people with HIV at the site 
       who were prescribed LAI ART. "Prescribed" is defined as the proportion of 
       clients prescribed LAI ART out of the number of clients interested and 
       eligible (if counseling and screening are consistently recorded) or out 
       of all PWH at the clinic (if counseling and screening are not consistently recorded).'),
    p('There are 8 plots: Overall, by sex, race, ethnicity, age, HIV 
       medication payor, and key populations, and prescribed over time.'),
    p('The Overall plot shows the percent prescribed out of the appropriate 
       denominator. The plots by sex, race, ethnicity, age, HIV medication payor, 
       and key populations have identical structure. They show the percent 
       prescribed out of the total number of clients in each demographic/social 
       determinant group. This enables quick and easy comparisons to understand 
       if there are any differences in prescribed by different variables. The 
       dashed line indicates the average, the same value in the Overall plot. 
       Bars above or below the average indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),

  info7a = tagList(
    p('This page shows the number and percentage of clients with HIV at the site who 
       could financially access LAI ART after being prescribed. "Accessible" is defined 
       as the proportion of clients able to financially access LAI ART out of clients 
       prescribed LAI ART within a given time period.'),
    p('Note that if a client initiated iCAB/RPV, they are considered to have been 
       able to access it financially. If a client was prescribed iCAB/RPV but did not 
       initiate it and the access variable was left blank or unknown, they are not 
       included in the "accessible" numerator.'),
    p('There are 9 plots: Overall, by sex, race, ethnicity, age, HIV medication payor, 
       and key populations, accessible over time, and not accessible reasons.'),
    p('The Overall plot shows the percent accessible out of the total clients ever 
       prescribed. The plots by sex, race, ethnicity, age, HIV medication payor, and 
       key populations have identical structure. They show the percent accessible out 
       of the total number of clients prescribed in each demographic/social determinant 
       group. This enables quick and easy comparisons to understand if there are any 
       differences in accessible by different variables. The dashed line indicates 
       the average, the same value in the Overall plot. Bars above or below the average 
       indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info8 = tagList(
    p('This page shows the number and percent of clients with HIV at your clinic 
       who initiated LAI ART. "Initiated" is defined as the proportion of clients 
       initiated on LAI ART (receiving at least 1 injection) out of clients prescribed LAI ART.'),
    p('There are 8 plots: Overall, by sex, race, ethnicity, age, HIV medication 
       payor, and key populations, and initiated over time.'),
    p('The Overall plot shows the percent initiated out of those prescribed. 
       The plots by sex, race, ethnicity, age, HIV medication payor, and key 
       populations have identical structure. They show the percent initiated out 
       of the total number of clients prescribed in each demographic/social 
       determinant group. This enables quick and easy comparisons to understand 
       if there are any differences in initiated by different variables. The 
       dashed line indicates the average, the same value in the Overall plot. 
       Bars above or below the average indicate differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info9 = tagList(
    p('This page shows the number and percentage of people with HIV at the site 
       currently sustained on LAI ART at the site among those initiated. "Sustained" 
       is defined as the proportion of clients sustained on LAI ART (still 
       receiving LAI ART) out of clients initiated on LAI ART.'),
    p('There are 9 plots: Overall, by sex, race, ethnicity, age, HIV medication 
       payor, and key populations, time spend on iCAB/RPV, and discontinued reasons.'),
    p('The Overall plot shows the percent sustained out of the total clients 
       ever initiated. The plots by sex, race, ethnicity, age, HIV medication 
       payor, and key populations have identical structure. They show the percent 
       sustained out of the total number of clients initiated in each 
       demographic/social determinant group. This enables quick and easy 
       comparisons to understand if there are any differences in sustained by 
       different variables. The dashed line indicates the average, the same 
       value in the Overall plot. Bars above or below the average indicate 
       differences occurring within that variable.'),
    p('Bars appear gray when the denominator is <10, to indicate the added uncertainty.')
  ),
  
  info10 = tagList(
    p('This page shows the numbers and percentages of early, on time, and 
       late injections out of all follow-up injections after the first injection. 
       "Early" is defined as occurring more than seven days before the target 
       injection date. "Late" is defined as occurring more than seven days after 
       the target injection date. The target injection date can be toggled on 
       the left, depending on the site\'s clinical practice. Either 28 or 56 days 
       (4 or 8 weeks), or 31 or 62 days (1 or 2 months) may be used to calculate 
       the target interval.'),
    p('"On time injections" shows the overall percentage of injections administered early, on time, and late.'),
    p('"On time injections by days since prior injection" shows how early or late particular 
       injections were, with the on time injection region shaded in gray There is a plot for 
       monthly injection intervals and a plot for bimonthly injection intervals.'),
    p('"Late injections by client" shows how many clients had how many late injections.'),
    p('"Early injections by client" shows how many clients had how many early injections.')
  ),
  
  info11 = tagList(
    p('This page shows viral load results among clients on iCAB/RPV. Different viral 
       load cutoffs of interest can be selected on the left sidebar. '),
    p('Viral Suppression: Users can define viral suppression as either a viral load 
       <50 copies/mL or <200 copies/mL. '),
    p('Elevated Viral Load: If users define viral suppression as <50 copies/mL, then 
       elevated viral load will be defined as VL>50 copies/mL. If users define viral 
       suppression as <200 copies/mL, then elevated viral load will be defined as 
       VL >200 copies/mL.   '),
    p('Treatment failure is defined as a (1) 1 VL >1000 copies/mL, or (2) 2 
       consecutive VL >200 copies/mL, or (3) emergent resistance at a given 
       time since initiating LAI ART out of all clients on LAI ART. '),
    p('By default, all uploaded viral load data will be shown. If you\'re 
       only intersted in specific years, check the "filter clients by active 
       year" box on the left panel to select the year(s) to include. '),
    p('The viral outcomes page includes the following six plots:'),
    tags$ul( 
      tags$li('Plot 1: Among clients who start iCAB/RPV with viremia 
               (not virally suppressed), what is the time to viral suppression?'),
      tags$li('Plot 2: Among clients who start iCAB/RPV virally suppressed, 
               what is the time to first elevated viral load?  '),
      tags$li('Plot 3: Among clients who start iCAB/RPV with viremia and 
               achieve viral suppression, what is the time to first elevated viral load?'),
      tags$li('Plot 4: Among clients who start iCAB/RPV virally suppressed, 
               what is the time to first treatment failure?  '),
      tags$li('Plot 5: Among clients who start iCAB/RPV with viremia and 
               achieve viral suppression, what is the time to first treatment failure?'),
      tags$li('Plot 6: Percent of clients virally suppressed at clinic on LAI ART vs. oral ART  ')
    ),
    p('Plots 1-5 are calculated using the Kaplan-Meier estimator. This gives 
       a conservative, statistical estimate of the time to the first occurrence 
       of the event, that accounts for the uncertainty and potential bias due to 
       clients discontinuing before they could have an outcome of interest (e.g., 
       viral suppression, elevated viral load) and/or and clients having variable 
       follow up time. Therefore, the percentages in the plots are statistical 
       estimates, not actual raw percentages and numbers. '),
    p('The number in parentheses at the bottom of each bar tells the user 
       the number of people contributing data to each data point in the plot. 
       Reviewing this number can give a sense of how certain or uncertain the 
       estimate is (with more data/people creating more certainty).'),
    p('Plots in the orange colorway distinguish outcomes for clients who 
       initiate iCAB/RPV with viremia. Plots in the blue colorway distinguish 
       outcomes for clients who initiate iCAB/RPV while virally suppressed.  ')
  )
  
)
