#ui.r

SP_list <- read.delim("S&P500_Anexo.txt", header = TRUE, stringsAsFactors = FALSE)

shinyUI(fluidPage(
  tags$head(includeScript("Google_Analytics.js")),
  titlePanel(title=div(img(src="logo.IQS.png"), "StockR")),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Gálvez, Martori, 2016. Big Data en las Finanzas: Estado de la cuestión y desarrollo de la aplicación StockR, Univ. Ramon Llull" ),
      br(),
      selectInput("symb", "Symbol", SP_list$Company,"^IBEX"),
    
      dateRangeInput("dates", 
        "Date range",
        start = "2016-01-01", 
        end = as.character(Sys.Date())),
      br(),

      checkboxInput("Bollinger", "Add Bollinger Bands"),
      checkboxInput("check_SMA_short", "Add SMA short term - Red Line", value = TRUE),
      numericInput("SMA_short", "SMA short term days", value = 20, min = 1, max = 45),
      checkboxInput("check_SMA_long", "Add SMA long term - Blue Line", value = TRUE),
      numericInput("SMA_long", "SMA long term days", value = 100, min = 50, max = 300),
      
      br(),
      
      checkboxInput("log", "Plot y axis on log scale", 
        value = FALSE),
      
      checkboxInput("adjust", 
        "Adjust prices for inflation", value = FALSE),
      br()
      
    ),
    
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Charts", br(), 
                           plotOutput("plot")),
                  tabPanel("Data", br(), dataTableOutput("dades")),
                  tabPanel("Recommendations", br(), tableOutput('mytable'))
      )
  )
)))