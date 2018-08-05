library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(
        navbarPage("API TREINAMENTO",
                        sidebarPanel(
                                uiOutput("songs_beatles"),
                                actionButton("bt_bsongs_all", label="Seleciona Todos"),
                                actionButton("bt_bsongs_none", label="Deseleciona Todos")
                        ),
                        sidebarPanel(
                                uiOutput("songs_stones"),
                                actionButton("bt_ssongs_all", label="Seleciona Todos"),
                                actionButton("bt_ssongs_none", label="Deseleciona Todos")
                        ),
                        mainPanel(
                                h4(textInput("txt_modelname", "Escreva o nome do modelo: ")),
                                actionButton("bt_train_model", label="Treinar modelo"),
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
