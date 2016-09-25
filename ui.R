#ui.r

SP_list <- read.delim("S&P500_Anexo.txt", header = TRUE, stringsAsFactors = FALSE)

shinyUI(fluidPage(
  titlePanel("stockR - Antonio Gálvez"),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput("symb", "Symbol", SP_list$Company,"^IBEX"),
    
      dateRangeInput("dates", 
        "Date range",
        start = "2016-01-01", 
        end = as.character(Sys.Date())),
      br(),

      checkboxInput("Bollinger", "Add Bollinger Bands"),
      checkboxInput("SMA_70days", "Add SMA 70 days - Red Line"),
      checkboxInput("SMA_200days", "Add SMA 200 days - Blue Line"),
      
      br(),
      
      checkboxInput("log", "Plot y axis on log scale", 
        value = FALSE),
      
      checkboxInput("adjust", 
        "Adjust prices for inflation", value = FALSE),
      br(),
      helpText("")
    ),
    
    mainPanel(
     plotOutput("plot"),
     br(),
     br(),
     br(),
     br(),
     br(),
     
     tableOutput('mytable'))
  )
))