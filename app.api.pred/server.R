
library(shiny)
library(tidyverse)
library(tuneR)
library(xgboost)

source("utils.R")
do_login_azure()

testsongs <- list_testsongs() %>% remove_extension_from_songnames()

available_models <- list_available_models()

shinyServer(function(input, output, session) {
        
        output$radioSongSelection <- renderUI({
                radioButtons('select_song', 
                             'Selecione a música para predição:', 
                             testsongs, selected=testsongs[1])})
        
        observeEvent(input$bt_refresh_songlist, 
             {  testsongs <- list_testsongs() %>% remove_extension_from_songnames();
                output$radioSongSelection <- renderUI({
                     radioButtons('select_song', 
                                  'Selecione a música para predição:', 
                                  testsongs, selected=testsongs[1]) })
             })
        
        # --- models choices -------------------------------------------------------
        output$radioModelSelection <- renderUI({
             radioButtons('select_model', 
                          'Selecione o modelo para predição:', 
                          available_models, selected=available_models[1]) })

        observeEvent(input$bt_refresh_modellist, 
                     {  available_models <- list_available_models();
                        output$radioModelSelection <- renderUI({
                             radioButtons('select_model', 
                                          'Selecione o modelo para predição:', 
                                          available_models, selected=available_models[1]) })
                     })
        
        observeEvent(input$bt_predict, {
                        pred_song <- input$select_song;
                        pred_model <- input$select_model;
                        prediction_answer <- predict_song(pred_song, pred_model);
                        output$prediction_answer <- renderText({ prediction_answer })
                     })
})
