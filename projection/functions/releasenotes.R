v0.0 <- function(){
p <- box(collapsible=T, title="v0.0", solidHeader=T, width=12, collapsed=T,
         div(
           em(h5("17-May-2021")),
           hr(),
           h3("Hello World"),
           p("This is the first version of the BeeHyvv company modeling dashoard."),
           h5(strong("What this dashboard is")),
           p("- A way to visualize company logic"),
           p("- A robust way of mapping that logic to numbers"),
           h5(strong("What this dashboardis not")),
           p("- The PnL of the bussiness"),
           p("- The backend of the business")
         ),
         hr(),
         div(
           h3("Functionality"),
           p("- ", strong("Growth rate modeling:"), " Modeling of Growth rate of daily acitve users as a sigmoid function with various tunables parameters"),
           p("- ", strong("Useful Graphs:"), " A view that visualizes Revenue, Gross Profit, and Cost of Revenue, that is generated from the growth rate of daily active users. 
                                       This view also shows the MoM 2-year projection of the company"), 
           p("- ", strong("Daily Data:"), " According to the tuned parameters of the Growth rate of Daily Active Users, and all the bussiness logic, various daily metrics are generated, 
                                       in a downloadable table format"),
           p("-", strong("Input:"),  " An view where the basic data input for the model to work happens. At this current time this is a \".xlsx\" file with the 
                                       expected Cost of Revenue on a monthly basis for a 2 years period"),
           p("- ", strong("Assumptions:"), " This is the most important tab. This includes in text all the logic behind the model. It is crusial for transparency
                                       and reproducability reasons. The goal is to be so transparent that the whole model could be replicated with excel formulas on the end users computer"),
           p("- ", strong("Version Release Notes:"), " With every new version of the dashboard (major updates in logic or structure), a new release note will be attached here")
         )
)
  return(p)
}