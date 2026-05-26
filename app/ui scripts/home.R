list(
  
  h1("Welcome"),
  #imageOutput("sites_img"),
  p('Welcome to the ALAI UP Dashboard'),
  p('The ALAI UP Dashboard is designed to help clinics monitor their long-acting 
     injectable HIV treatment (LAI ART) programs.'),
  p('The Dashboard Toolkit can be used by clinic leadership, LAI ART program leads, 
     data management and quality teams, and other stakeholders to:'),
  tags$ul(
    tags$li('Track progress toward their implementation goals for their LAI ART program.'),
    tags$li('Identify gaps in LAI ART care delivery across different social determinants of health.'),
    tags$li('Guide efforts to address gaps and improve the quality of services for all clients.')
  ),
  p('Please refer to the Dashboard Toolkit for detailed instructions on preparing your data and using the dashboard.'),
  h3('Instructions'),
  p(strong('The Dashboard is organized into the following sections designed to support
    at-a-glance data review, and more in-depth data exploration. If you have multiple
    locations, you can select a 
    clinical site to review, then navigate to one of the sections below. Data for all sites
    is selected by default. If you do not have multiple clinic locations, continue below.')),
  p("If counseling and screening (also called 'assessment') are not consistently recorded 
     at your site, select 'No' in the top left. This will focus the indicators and calculations
     on clients prescribed LAI ART only. If counseling and screening is consistently recorded,
     continue below."),
  tags$ol(   
    tags$li('Clinic Demographics. This page shows clinic demographic data for 
            clients overall and by client characteristics, overall and stratified by LAI use. 
            To view demographic data, click on 
            "Clinic Demographics" in the menu on the left of the page.'),
    br(),
    tags$li('LAI Indicators. This section shows the LAI care gaps throughout 
            the care continuum: number and percent assessed, eligible, prescribed,
            initiated, sustained. 
            To view the LAI care indicator, click on "LAI Indicators" on the left of the page. 
            Once you click on LAI indicators in the menu, a new menu will open with a 
            column on the left showing all the indicators you can look at for
            your site.'),
    br(),
    tags$li('Clinical Outcomes. This section shows clinical outcomes for LAI clients: 
            number and percent of PWH on LAI who received LAI 
            early, on time, or late, and time to viral suppression and viral failure.
            There is also data on clinic-level viral load, including clients on oral ART.'),
    br(),    
    tags$li('Data Explore. This page allows you to dive deeper into your data,
            by viewing LAI indicators disaggregated by up to two variables at 
            once. If you want to view more detailed data subset by two variables
            at once, click on the "Data Explorer" tab. There are detailed 
            instructions there for using the data explorer.')
  ),
  br(),
  br(),
  br(),
  p('The development of the ALAI UP (Accelerating Implementation of 
    Multilevel-strategies to Advance Long-Acting Injectables for Underserved 
    Populations) dashboard was financially supported by the Health Resources 
    and Services Administration (HRSA), Department of Health and Human Services 
    (HHS) U1SHA46532. The award provided 100% 
    of total costs and totaled $7,450,000. The contents are those of the developers. 
    They may not reflect the policies of HRSA, HHS, or the U.S. Government.'),
  p('This Version 1.0 was completed on 3/20/2026.')
  
)
  
  