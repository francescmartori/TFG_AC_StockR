# server.R

library(quantmod)
library(shiny)
source("helpers.R")
SP_list <- read.delim("S&P500_Anexo.txt", header = TRUE, stringsAsFactors = FALSE)

shinyServer(function(input, output) {

  dataInput <- reactive({
    from_date <- as.POSIXlt(as.Date(input$dates[1], format = "%m/%d/%Y"))
    from_date$mon <- from_date$mon - 10
    
    getSymbols(SP_list[SP_list$Company == input$symb, ]$Symb, src = "yahoo", 
               from = from_date, 
               to = input$dates[2],
               auto.assign = FALSE)
  })
  
  output$plot <- renderPlot({   
    data <- dataInput()
    if (input$adjust) data <- adjust(dataInput())
    
    opciones <- "addVo();"  
    opciones <- paste(opciones, if(input$Bollinger) "addBBands();", sep = "")
    opciones <- paste(opciones, if(input$check_SMA_short) paste("addSMA(n=", input$SMA_short, ",col=2);", sep = ""))
    opciones <- paste(opciones, if(input$check_SMA_long) paste("addSMA(n=", input$SMA_long, ",col=4);", sep = ""))
    
    chartSeries(data, theme = chartTheme("white"), 
                type = "line", 
                log.scale = input$log, 
                TA = opciones,
                name = input$symb,
                subset=paste(input$dates[1],"::",input$dates[2], sep=""))
    }, height = 450, width = 700)
  
    output$mytable = renderTable({
      
      table <- data.frame("Technical Indicator" = c("Bollinger", "Medias", "Global"),
                          "Recommendations" =  factor(x = rep("Neutro", 3), levels = c("Comprar", "Vender", "Neutro")))
      
      if(input$Bollinger) {
        data <- dataInput()
        if (input$adjust) data <- adjust(dataInput())
        
        boll <- BBands(data[, 4])
        
        if(tail(boll$up, n=1) < tail(data, n=1)[,4]) {
          table[1,2] <- "Vender"
        } else if(tail(boll$dn, n=1) > tail(data, n=1)[,4]) {
          table[1,2] <- "Comprar"
        }
      }
      
      if(input$check_SMA_short & input$check_SMA_long) {
        data <- dataInput()
        if (input$adjust) data <- adjust(dataInput())
        
        SMA_S <- SMA(data[,4], n = input$SMA_short)
        SMA_L <- SMA(data[,4], n = input$check_SMA_long)
        
        if(tail(SMA_S, n=1) > tail(SMA_L, n=1)) {
          table[2,2] <- "Comprar"
        } else if(tail(SMA_S, n=1) < tail(SMA_L, n=1)) {
          table[2,2] <- "Vender"
        }
      }
      
      if(table$Recommendations[1] == table$Recommendations[2]) {
        table$Recommendations[3] <- table$Recommendations[1]
      }
      
      table
    })
  
  output$dades <- renderDataTable(dataInput())
})