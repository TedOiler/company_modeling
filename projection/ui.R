source('./functions/logic.R')
source('./functions/releasenotes.R')
library(shiny)
library(shinydashboard)
library(tidyr)
library(dplyr)
library(readr)
library(broom)
library(ggplot2)
library(lubridate)
library(DT)
library(plotly)
library(readxl)

shinyUI(dashboardPage(
    
    dashboardHeader(title="BeeHyvv v0.0"),
    
    dashboardSidebar(
        sidebarMenu(
            menuItem(
                "Input",
                    tabName="input_data",
                icon=icon("info")
            ),
            menuItem(
                    "Growth rate Modeling",
                    tabName="growth_modeling",
                    icon=icon("poll")
                    ),
            menuItem(
                    "Useful Graphs",
                    tabName="useful_graphs",
                    icon=icon("dollar-sign")
            ),
            menuItem(
                    "Daily Data",
                     tabName="data_projection",
                     icon=icon("table")
                    ),
            menuItem(
                    "Assumptions",
                     tabName="model_assumptions",
                     icon=icon("file")
                    ),
            menuItem(
                    "Version Release Notes",
                    tabName="release_notes",
                    icon=icon("bullhorn")
            )
        )
    ),
    
    dashboardBody(
        tabItems(
            tabItem(tabName="input_data",
                    fluidRow(
                        box(width=6,
                            fileInput("file", "Choose a file to upload"),
                            dateRangeInput("daterange", "Date range:",
                                           start = "2021-01-01",
                                           end   = "2022-12-31",
                                           format = "dd/mm/yy"),
                            hr(),
                            p("The data must be in a format of:"),
                            p("- column 1 name: date"),
                            p("- column 2 name: CoR"),
                            p("- column 1 format: DD/MM/YY, example - 01/03/21 (meaning March 2021)"),
                            p("- column 2 format: number, example - 62.35 (meaning for March 2021 the Cost of Revenue is 62.35€"),
                            p("*Note: Each row represents one month, therefore if the first row has a date of 01/01/21, the next should be 01/02/21")
                        ),
                        box(width=6,
                            dataTableOutput("monthly_CoR"))
                    )
                    
            ),
            tabItem(tabName="growth_modeling", 
                    fluidRow(
                        box(collapsible=T, title="Parameters", status="primary", solidHeader=T,
                            box(sliderInput(inputId="i_weight",
                                            label="B- Growth rate",min=0,max=0.1,value=0.05,step=0.001)),
                            
                            box(sliderInput(inputId="i_from",
                                            label="A - Lower Bound",min=0,max=1,value=0,step=0.1)),
                            
                            box(sliderInput(inputId="i_to",
                                            label="K - Upper Bound",min=0,max=9,value=1,step=0.1)),
                            
                            box(sliderInput(inputId="i_when",
                                            label="Q - Delay",min=0,max=100,value=1,step=0.1)),
                            
                            box(numericInput(inputId="i_cmu", "Critical Mass of Users:", 100, min=1, max=10000)),
                            
                            box(numericInput(inputId="i_start", "Users for day 0:", 15, min=1, max=10000)),
                        ),
                        
                        box(collapsible=T, title="Growth Rate of DAU", footer="2 Year Projection", status="primary", solidHeader=T,
                            plotlyOutput("growth_function")
                        )
                    )),
            tabItem(tabName="useful_graphs",
                    fluidRow(
                        box(collapsible=T, title="Revenue", footer="2 Year Projection", status="primary", solidHeader=T, width=6,
                            plotlyOutput("gp_function")),
                        box(collapsible=T, title="Break Even Point", footer="2 Year Projection", status="primary", solidHeader=T, width=6,
                            plotlyOutput("gp_integral_function"))
                    ),
                    fluidRow(
                        box(collapsible=T, title="Projected PnL", footer="2 Year Projection", status="primary", solidHeader=T, width=12,
                            dataTableOutput("pnl_projection"))
                    )
            ),
            tabItem(tabName="data_projection",
                    downloadButton('downloadData', 'Download'),
                    dataTableOutput("data_table")
            ),
            tabItem(tabName="model_assumptions",
                    fluidRow(
                        htmlOutput("pdfview")
                    )
            ),
            tabItem(tabName="release_notes",
                    fluidRow(
                        v0.0()
                    )
            )
        )
    )
))
