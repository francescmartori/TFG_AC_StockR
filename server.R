# server.R

library(quantmod)
source("helpers.R")

shinyServer(function(input, output) {

  dataInput <- reactive({
    from_date <- as.POSIXlt(as.Date(input$dates[1], format = "%m/%d/%Y"))
    from_date$mon <- from_date$mon - 10
    
    getSymbols(input$symb, src = "yahoo", 
               from = from_date, 
               to = input$dates[2],
               auto.assign = FALSE)
  })
  
  output$plot <- renderPlot({   
    data <- dataInput()
    if (input$adjust) data <- adjust(dataInput())
    
    opciones <- "addVo();"  
    opciones <- paste(opciones, if(input$Bollinger) "addBBands();", sep = "")
    opciones <- paste(opciones, if(input$SMA_70days) "addSMA(n=70, col=2);", sep = "")
    opciones <- paste(opciones, if(input$SMA_200days) "addSMA(n=200, col=4);", sep = "")
    
    chartSeries(data, theme = chartTheme("white"), 
                type = "line", 
                log.scale = input$log, 
                TA = opciones,
                name = input$symb,
                subset=paste(input$dates[1],"::",input$dates[2], sep=""))
    
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
      
      if(input$SMA_70days & input$SMA_200days) {
        data <- dataInput()
        if (input$adjust) data <- adjust(dataInput())
        
        SMA70 <- SMA(data[,4], n = 70)
        SMA200 <- SMA(data[,4], n = 200)
        
        if(tail(SMA70, n=1) > tail(SMA200, n=1)) {
          table[2,2] <- "Comprar"
        } else if(tail(SMA70, n=1) < tail(SMA200, n=1)) {
          table[2,2] <- "Vender"
        }
      }
      
      if(table$Recommendations[1] == table$Recommendations[2]) {
        table$Recommendations[3] <- table$Recommendations[1]
      }
      
      table
    })   
  }, height = 450, width = 700)
  
  
})