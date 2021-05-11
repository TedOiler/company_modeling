library(shiny)
library(shinydashboard)
library(tidyr)
library(dplyr)
library(readr)
library(broom)
library(ggplot2)
library(lubridate)
library(DT)

# ------------------------------------------------------------------------------
# https://en.wikipedia.org/wiki/Generalised_logistic_function
# A: the lower asymptote;
# K: the upper asymptote when C=1;
# B: the growth rate;
# n >0 : affects near which asymptote maximum growth occurs;
# Q: is related to the value Y(0);
# C: typically takes a value of 1;
sigmoid = function(A=0,K=1,C=1,Q=1,B=1,n=1, x) {
    y <- A + (K-A) / (C + Q*exp(-B*x))^(1/n) 
    return(y)
}

add.growth <- function(data, B, A, K, Q, n){
    data <- data %>% 
        mutate(growth=sigmoid(x=x, B=B, A=A, K=K, Q=Q, n=n))
    return(data)
}

add.dau <- function(data) { #daily active users
    data <- data %>% 
        mutate(dau=15*(1+lag(growth, default = 0)))
    return(data)
}

add.margin <- function(data){
    data <- data %>% 
        mutate(margin=-0.5*(dau<=18)+0.8*(dau>18))
    
    return(data)
}

add.daily.rev <- function(data){
    data <- data %>% 
        mutate(daily.rev=daily.CoR/(1-margin))
    return(data)
}

add.daily.gross.profit <- function(data){
    data <- data %>% 
        mutate(daily.gross.profit=daily.rev-daily.CoR)
    return(data)
}

monthly.cor <- read_csv("./data/CoR.csv")
monthly.cor <- monthly.cor %>% mutate(
    date=strptime(as.character(date), "%d/%m/%Y"),
    date=format(date, "%Y-%m-%d"),
    date=as.Date(date),
    id.col=paste0(month(date),year(date)))

daily.data <- data.frame(date=seq(as.Date("21-01-01"), as.Date("22-12-31"), by="days"))
daily.data <- daily.data %>% mutate(
    id.col=paste0(month(date),year(date))) %>% 
    left_join(monthly.cor) %>%
    fill(CoR) %>%
    rename(
        monthly.CoR = CoR
    ) %>% 
    select(-id.col) %>% 
    mutate(
        days.of.month = days_in_month(date),
        daily.CoR = monthly.CoR/days.of.month,
        x=seq(-365,364,1),
        ## growth=sigmoid(x=x),
        ## daily.active.usr = 15*(1+lag(growth, default = 0)),
        ## margin=-(0.5*(daily.active.usr<15))+0.8*(daily.active.usr>15),
        ## daily.rev=daily.CoR/(1-margin),
        ## daily.gross.rev=daily.rev-daily.CoR
    )


ui <- dashboardPage(
    dashboardHeader(title="Company Modeling"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Growth rate Modeling",
                     tabName="growth_modeling",
                     icon=icon("poll")),
            menuItem("Daily Data",
                     tabName="data_modeling",
                     icon=icon("table")),
            menuItem("Assumptions",
                     tabName="model_assumptions",
                     icon=icon("file"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName="growth_modeling", 
                    box(box(sliderInput(inputId="i_weight",
                                        label="B- Growth rate",min=0,max=0.1,value=0.05,step=0.0001)),
                        box(sliderInput(inputId="i_from",
                                        label="A - Lower Bound",min=0,max=1,value=0,step=0.001)),
                        box(sliderInput(inputId="i_to",
                                        label="K - Upper Bound",min=0,max=5,value=1,step=0.001)),
                        box(sliderInput(inputId="i_when",
                                        label="Q - Critical mass of Users",min=0,max=100,value=1,step=0.1)),
                        box(sliderInput(inputId="i_conv",
                                        label="n - Delay",min=0,max=1,value=1,step=0.001)),
                        collapsible=TRUE, title="Parameters"),
                    box(plotOutput("growth_function"), collapsible=TRUE, title="Growth Rate of DAU", footer="For 2 years"),
                    box(plotOutput("gp_function"), collapsible=TRUE, title="Revenue", footer="For 2 years"),
                    box()
                    ),
            tabItem(tabName="data_modeling",
                    downloadButton("downloadData", "Download"),
                    dataTableOutput("data_table")
                    ),
            tabItem(tabName="model_assumptions",
                    textOutput("test\ntest"))
        )
    )
)
    
server <- function(input, output){
    
    output$growth_function <- renderPlot({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when,
                               n=input$i_conv)
        
        
        table_df %>% 
            ggplot(aes(ymd(date),growth)) + 
            geom_line() +
            theme_linedraw()
    })
    
    output$gp_function <- renderPlot({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when,
                               n=input$i_conv)
        table_df <- add.dau(data=table_df)
        table_df <- add.margin(data=table_df)
        table_df <- add.daily.rev(data=table_df)
        table_df <- add.daily.gross.profit(data=table_df)
        
        table_df %>% 
            ggplot() + 
            geom_line(aes(ymd(date),daily.gross.profit), col="blue4") +
            geom_line(aes(ymd(date),daily.rev), col="green4") +
            geom_line(aes(ymd(date),daily.CoR), col="red4") +
            theme_linedraw()
    })

    output$data_table <- renderDataTable({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when,
                               n=input$i_conv)
        table_df <- add.dau(data=table_df)
        table_df <- add.margin(data=table_df)
        table_df <- add.daily.rev(data=table_df)
        table_df <- add.daily.gross.profit(data=table_df)
        
        table_df %>% 
            select(-x)
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$data, ".csv", sep = ",")
        },
        content = function(file) {
            write.csv(datasetInput(), file, row.names = FALSE)
        }
    )
} 

    
shinyApp(ui = ui, server = server)