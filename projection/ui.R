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
source('./functions/logic.R')

shinyUI(dashboardPage(
    
    dashboardHeader(title="Company Modeling"),
    
    dashboardSidebar(
        sidebarMenu(
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
                     tabName="data_modeling",
                     icon=icon("table")
                    ),
            menuItem(
                    "Assumptions",
                     tabName="model_assumptions",
                     icon=icon("file")
                    )
        )
    ),
    
    dashboardBody(
        tabItems(
            tabItem(tabName="growth_modeling", 
                    fluidRow(
                        box(collapsible=TRUE, title="Parameters", status="primary", solidHeader = TRUE,
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
                        
                        box(collapsible=TRUE, title="Growth Rate of DAU", footer="2 Year Projection", status="primary", solidHeader = TRUE,
                            plotlyOutput("growth_function")
                        )
                    )),
            tabItem(tabName="useful_graphs",
                    fluidRow(
                        box(collapsible=TRUE, title="Revenue", footer="2 Year Projection", status="primary", solidHeader = TRUE, width = 12,
                            plotlyOutput("gp_function"))
                    ),
                    fluidRow(
                        box(collapsible=TRUE, title="Break Even Point", footer="2 Year Projection", status="primary", solidHeader = TRUE, width = 12,
                            plotlyOutput("gp_integral_function"))
                    )
            ),
            tabItem(tabName="data_modeling",
                    downloadButton("downloadData", "Download"),
                    dataTableOutput("data_table")
            ),
            tabItem(tabName="model_assumptions",
                    fluidRow(
                        box(
                            verbatimTextOutput(outputId="i_txt", placeholder = TRUE), 
                            collapsible=TRUE, status="primary", solidHeader = TRUE, width = 12))
            )
        )
    )
))
