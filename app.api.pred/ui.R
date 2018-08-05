library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(
        navbarPage("API PREDIÇÃO",
                        sidebarPanel(
                                uiOutput("radioSongSelection"),
                                actionButton("bt_refresh_songlist", label="Atualiza lista")
                        ),
                        mainPanel(
                                uiOutput("radioModelSelection"),
                                actionButton("bt_refresh_modellist", label="Atualiza lista"),
                                actionButton("bt_predict", label="Predita"),
                                h2(textOutput("prediction_answer")),
                                tags$head(tags$style(type="text/css", "
                                     #loadmessage {
                                       position: fixed;
                                       top: 100px;        
                                       left: 0px;
                                       width: 100%;
                                       padding: 5px 0px 5px 0px;
                                       text-align: center;
                                       font-weight: bold;
                                       font-size: 100%;
                                       color: #000000;
                                       background-color: #CCFF66;
                                       z-index: 105;
                                     }
                                  ")),
                                conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                 tags$div("Processando...",id="loadmessage"))
                        )
           )
))
