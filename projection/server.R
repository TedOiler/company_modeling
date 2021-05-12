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

monthly.cor <- read_csv("./data/CoR.csv")
monthly.cor <- monthly.cor %>% mutate(
    date=strptime(as.character(date), "%d/%m/%Y"),
    date=format(date, "%Y-%m-%d"),
    date=as.Date(date),
    id.col=paste0(month(date),year(date)),
    CoR=-CoR)

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
        x=seq(-365,364,1)
    )


shinyServer(function(input, output){
    
    output$growth_function <- renderPlotly({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when,
                               n=input$i_conv)
        
        
        table_df %>% 
            ggplot(aes(ymd(date),growth)) + 
            geom_line() +
            theme_bw()
    })
    
    output$gp_function <- renderPlotly({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when)
        table_df <- add.dau(data=table_df, start=input$i_start)
        table_df <- add.margin(data=table_df, cmu=input$i_cmu)
        table_df <- add.daily.rev(data=table_df)
        table_df <- add.daily.gross.profit(data=table_df)
        
        table_df %>% 
            ggplot() + 
            geom_line(aes(ymd(date),daily.gross.profit), col="blue4") +
            geom_line(aes(ymd(date),daily.rev), col="green4") +
            geom_line(aes(ymd(date),daily.CoR), col="red4") +
            geom_hline(yintercept=0, linetype="dashed", color = "grey40") +
            labs(x = "Days",
                 y = "(€)",
                 color = "Legend") +
            theme(legend.position = "bottom") +
            theme_bw()
    })
    
    output$data_table <- renderDataTable({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when,
                               n=input$i_conv)
        table_df <- add.dau(data=table_df, start=input$i_start)
        table_df <- add.margin(data=table_df, cmu=input$i_cmu)
        table_df <- add.daily.rev(data=table_df)
        table_df <- add.daily.gross.profit(data=table_df)
        
        table_df %>% 
            select(-x)
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("daily_data.csv")
        },
        content = function(file) {
            write.table(table_df, file, row.names = FALSE, sep=',')
        }
    )
    
    output$gp_integral_function <-  renderPlotly({
        table_df <- add.growth(data=daily.data,
                               B=input$i_weight,
                               A=input$i_from,
                               K=input$i_to,
                               Q=input$i_when)
        table_df <- add.dau(data=table_df, start=input$i_start)
        table_df <- add.margin(data=table_df, cmu=input$i_cmu)
        table_df <- add.daily.rev(data=table_df)
        table_df <- add.daily.gross.profit(data=table_df)
        table_df <- add.gp.running.sum(data=table_df)
        
        table_df %>% 
            ggplot() + 
            geom_area(aes(ymd(date), gp.running.sum), fill="lightblue", lwd=2) +
            geom_hline(yintercept=0, linetype="dashed", color = "grey40") +
            theme_bw()
    })
    output$i_txt <- renderText({ "test" })
} )
