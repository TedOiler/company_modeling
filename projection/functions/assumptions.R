library(mathjaxr)

# --------------------------------------------------------------------------------------------------------------
v0 <- function() {
  p <-
    box(
      collapsible = T,
      title = "v0.*",
      solidHeader = T,
      width = 12,
      collapsed = F,
      div(
        em(h5("17-May-2021")),
        hr(),
        h3("Purpose of Existance"),
        p(
          "The current version of the model is a ",
          strong("proof of concept"),
          ", that can be
               adjusted/extended to accommodate the logic of the business."
        ),
        p(
          "The goal of this dashboard is to model the first 2 years of the business in terms of:"
        ),
        tags$li("Profit and Loss (PnL)"),
        tags$li("Cashburn (CB)"),
        tags$li("Balance Sheet (BS)"),
        p(""),
        p("In this current verions (v0.0), only the PnL is materialized"),
        hr(),
        h3("Modeling Logic"),
        p(
          "There exists a Critical Mass of Users (CMU), after which the platform
               is sufficiently established as the main player in the market (establishes
               Dominant Position). Before having that CMU, the margins of the company
               have to be small because the focus should be in acquiring new users rather
               than profit, while after that CMU the margins can start potentially to increase."
        ),
        p(
          "Therefore, if we assume that the Daily Active Users (DAU) have a growth rate
          that is a function of time, we can model how many DAU we have each day."
        ),
        tags$ol(
          tags$li("Daily Cost of Revenue (CoR) is given as input to the model"),
          tags$li(
            "The growth rate of DAU is a ",
            a(href = "https://en.wikipedia.org/wiki/Generalised_logistic_function", "sigmoid", target =
                "_blank"),
            "of time. That means that for every day of the initial 2 years the growth rate starts from
                  the lower limit (parameter A), and rises until it reaches a pick (parameter K). These parameters can be adjusted on the tab
                  \"Growth Rate Modeling\""
          ),
          tags$li(
            "The DAU are a function of their growth rate defined above and the DAU on day zero,
                  which has to be greater than 0 for the model to make sense"
          ),
          tags$li("margin = ((daily revenue) - (daily cost)) / (daily cost)"),
          tags$li(
            "The Margin is set to be -0.5 (-50%) when users are less than CMU (adjustable parameter on
                  the tab \"Growth Rate Modeling\") and 0.8 (80%) when DAU is greater or equal to CMU"
          ),
          tags$li(
            "Therefore, since we have the (daily cost) as a given and the margin as a function of the above,
                  we can calculate (daily revenue) as: (daily revenue) = (daily cost)/(1-margin)"
          ),
          tags$li(
            "Finally since we have (Daily Revenue) and (daily Cost of Revenue), we can aggregate
                  to the monthly level and have an estimate/projection of the PnL of the business in the 2 year perior"
          )
        ),
        hr(),
        h3("Comments"),
        p(
          "Numbers (2), (3), and (5) can be adjusted according to business logic to create a more robust projections."
        ),
        p(
          "The ultimate goal of the project is to finalize the logic and estimate all parameters accurately from any data
          source collected to see wheather the business can generate enough Profit."
        ),
        p(
          "Further modeling is of course possible, for example, adding overhead costs such as SGnA and Taxes to model the whole
          managerial PnL until net Revenue"
        ),
        p(
          "The most important thing in this stage is to set up a common languge of conversation, and extend the
          above logic to include the other accounting books as well, most importantly the Cashburn CB."
        )
      )
    )
  return(p)
}