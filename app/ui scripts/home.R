list(
  
  h1("Welcome"),
  #imageOutput("sites_img"),
  p('Welcome to the ALAI UP Dashboard'),
  p('The ALAI UP Dashboard is a comprehensive, web-based platform designed to help 
     clinics monitor their long-acting injectable HIV treatment (LAI ART) programs.'),
  p('The Dashboard Toolkit can be used by clinic leadership, LAI ART program leads, 
     data management and quality teams, and other stakeholders to:'),
  tags$ul(
    tags$li('Track progress toward their implementation goals for their LAI ART program.'),
    tags$li('Identify gaps in LAI ART care delivery across different social determinants of health.'),
    tags$li('Guide efforts to address gaps and improve the quality of services for all clients.')
  ),
  p('Please refer to the ',
     list((function() { 
      tag <- tags$a("Dashboard Toolkit", href = "1. DRAFT - ALAI UP Dashboard Toolkit.docx")
      tag})()),
     ' for detailed instructions on preparing your data and using the dashboard. 
     A file with simulated data for testing out the dashboard is available for download ',
     list((function() {
      tag <- tags$a("here.", href = "simulated_data.xlsx")
      tag$attribs$download <- NULL
      tag})()
    )
  ),
  br(),
  br(),
  br(),
  p('The development of the ALAI UP (Accelerating Implementation of Multilevel-strategies 
  to Advance Long-Acting Injectables for Underserved Populations) dashboard was financially 
  supported by the Health Resources and Services Administration (HRSA), Department of Health 
  and Human Services (HHS) U1SHA46532. The award provided 100% of total costs and totaled $7,450,000. 
  The contents are those of the developers. They may not reflect the policies of HRSA, HHS, or the U.S. Government.'),
  p('This Version 1.0 was completed on 6/2/2026.')
  
)
  
  