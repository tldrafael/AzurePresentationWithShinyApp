
library(shiny)
library(tidyverse)
source("azure_calls.R")

do_login_azure()
trainsongs <- list_trainsongs()
get_basename_songs_by_artist <- function(artist){
        grep(trainsongs, pattern=artist, value=TRUE) %>% 
                map_chr(~str_split(.x, "-")[[1]][2])  %>% 
                map_chr(~gsub(.x, pattern="\\.wav", replacement=""))
}

songs_beatles <- get_basename_songs_by_artist("beatles")
songs_stones <- get_basename_songs_by_artist("stones")

shinyServer(function(input, output, session) {
        
        # --- Write train music options ----------------------------------------------
        output$songs_beatles <- renderUI({
                checkboxGroupInput("songs_beatles", "Escolha as músicas dos Beatles:", 
                                   choices=songs_beatles, selected=sample(songs_beatles, 1))
        })
        output$songs_stones <- renderUI({
                checkboxGroupInput("songs_stones", "Escolha as músicas dos Stones:", 
                                   choices=songs_stones, selected=sample(songs_stones, 1))
        })
        
        ## --- update the sidebar with select/unselect all buttons --------------------
        observeEvent(input$bt_bsongs_none, 
             updateCheckboxGroupInput(session=session, inputId="songs_beatles", 
                                      choices=songs_beatles, selected=NULL)
        )
        observeEvent(input$bt_bsongs_all, 
             updateCheckboxGroupInput(session=session, inputId="songs_beatles", 
                                      choices=songs_beatles, selected=songs_beatles)
        ) 
        observeEvent(input$bt_ssongs_none, 
                     updateCheckboxGroupInput(session=session, inputId="songs_stones", 
                                              choices=songs_stones, selected=NULL)
        )
        observeEvent(input$bt_ssongs_all, 
                     updateCheckboxGroupInput(session=session, inputId="songs_stones", 
                                              choices=songs_stones, selected=songs_stones)
        )
        
        # --- modeling -------------------------------------------------------------
        observeEvent(input$bt_train_model, {
                input_songs_beatles <- input$songs_beatles;
                input_songs_stones <- input$songs_stones;
                input_modelname <- input$txt_modelname;
                create_trainjob(input_songs_beatles, input_songs_stones, input_modelname)
        })
        
})
