source('./functions/logic.R')
library(shiny)
library(tidyr)
library(dplyr)
library(readr)
library(broom)
library(ggplot2)
library(lubridate)
library(DT)
library(plotly)
# library(googlesheets4)

shinyServer(function(input, output) {
    # to showcase the uploaded input file
    output$monthly_CoR <- renderDataTable({
        file_to_read <- input$file
        if (is.null(file_to_read)) {
            return()
        }
        read_excel(file_to_read$datapath)
    })
    
    # read the input file with CoR
    monthly.cor.process <- reactive({
        # gs4_deauth() # to access the gsheet below
        file_to_read <- input$file
        if (is.null(file_to_read)) {
            return()
        }
        excel <- as.data.frame(read_excel(file_to_read$datapath))
        # excel <- as.data.frame(read_sheet("1DfsfbGO5qY3RkRwymwdkDpp9fYLj5GBZeqRLkfR_63A"))
        excel <- excel %>% mutate(
            date = strptime(as.character(date), "%d/%m/%Y"),
            date = format(date, "%Y-%m-%d"),
            date = as.Date(date),
            id.col = paste0(month(date), year(date)),
            CoR = -CoR
        )
        excel
    })
    
    # convert it into the daily data format, suitable for analysis
    daily.data <- reactive({
        daily.data <-
            data.frame(date = seq(as.Date("21-01-01"), as.Date("22-12-31"), by = "days"))
        # daily.data <- data.frame(date=seq(input$daterange[1], input$daterange[2], by="days")) # find out why this doesn't work
        daily.data <- daily.data %>%
            mutate(id.col = paste0(month(date), year(date))) %>%
            left_join(monthly.cor.process()) %>%
            fill(CoR) %>%
            rename(monthly.CoR = CoR) %>%
            select(-id.col) %>%
            mutate(
                days.of.month = days_in_month(date),
                daily.CoR = monthly.CoR / days.of.month,
                x = seq(-365, 364, 1)
            )
        table_df <- add.growth(
            data = daily.data,
            B = input$i_weight,
            A = input$i_from,
            K = input$i_to,
            Q = input$i_when
        )
        table_df <- add.dau(data = table_df, start = input$i_start)
        table_df <- add.margin(data = table_df, cmu = input$i_cmu)
        table_df <- add.daily.rev(data = table_df)
        table_df <- add.daily.gross.profit(data = table_df)
        table_df <- add.gp.running.sum(data = table_df)
        
        table_df
    })
    
    # plot for growth rate function TODO: add legend, fix labels
    output$growth_function <- renderPlotly({
        table_df <- daily.data()
        
        table_df %>%
            ggplot(aes(ymd(date), growth)) +
            geom_line() +
            theme_bw()
    })
    
    # plot for revenue growh rate and gp functions TODO: add legend, fix labels
    output$gp_function <- renderPlotly({
        table_df <- daily.data()
        
        table_df %>%
            ggplot() +
            geom_line(aes(ymd(date), daily.gross.profit), col = "blue4") +
            geom_line(aes(ymd(date), daily.rev), col = "green4") +
            geom_line(aes(ymd(date), daily.CoR), col = "red4") +
            geom_hline(yintercept = 0,
                       linetype = "dashed",
                       color = "grey40") +
            labs(x = "Days",
                 y = "(€)",
                 color = "Legend") +
            theme(legend.position = "bottom") +
            theme_bw()
    })
    
    # plot for break even point TODO: add legend, fix labels
    output$gp_integral_function <-  renderPlotly({
        table_df <- daily.data()
        
        table_df %>%
            ggplot() +
            geom_area(aes(ymd(date), gp.running.sum),
                      fill = "lightblue",
                      lwd = 2) +
            geom_hline(yintercept = 0,
                       linetype = "dashed",
                       color = "grey40") +
            theme_bw()
    })
    
    # data table of daily data
    output$data_table <- renderDataTable({
        table_df <- daily.data()
        
        table_df %>%
            select(-x, -gp.running.sum)
    },
    options = list(scrollX = T))
    
    # download logic for daily data
    output$downloadData <- downloadHandler(filename <- function() {
        paste('data-', Sys.Date(), '.xlsx', sep = '')
        
    },
    content <- function(con) {
        download_data <- daily.data() %>%
            select(-x, -gp.running.sum)
        write.csv(download_data, con)
    })
    
    projection <- reactive({
        table_df <- daily.data()
        
        table_df %>%
            pivot_longer(
                cols = c(daily.rev, daily.CoR, daily.gross.profit),
                names_to = "Metric",
                values_to = "numbers"
            ) %>%
            select(-monthly.CoR,
                   -days.of.month,
                   -x,
                   -growth,
                   -dau,
                   -margin) %>%
            mutate(month = format(date, "%m"),
                   year = format(date, "%Y")) %>%
            group_by(year, month, Metric) %>%
            summarise(total = round(sum(numbers), 2)) %>%
            ungroup() %>%
            mutate(month.year = paste(month, year, sep = "-")) %>%
            select(-month, -year) %>%
            pivot_wider(names_from = month.year,
                        values_from = total) %>%
            slice(match(
                c("daily.rev", "daily.CoR", "daily.gross.profit"),
                Metric
            )) %>%
            mutate(
                Metric = recode(
                    Metric,
                    daily.rev = "Revenue",
                    daily.CoR = "Cost of Revenue",
                    daily.gross.profit = "Gross Profit"
                )
            )
    })
    
    output$pnl_projection <- renderDataTable({
        projection()
    },
    options = list(dom = 't', scrollX = T))
    
    # download projected PnL for daily data
    output$downloadProjection <- downloadHandler(filename <-
                                                     function() {
                                                         paste('data-', Sys.Date(), '.xlsx', sep = '')
                                                     },
                                                 content <-
                                                     function(con) {
                                                         download_pnl <- projection()
                                                         write.csv(download_pnl, con)
                                                     })
})
