
remove_extension_from_songnames <- function(songnames){
        map_chr(songnames, ~gsub(.x, pattern="\\.wav", replacement=""))
}

do_login_azure <- function(){
        CMD <- paste0("az login --service-principal",
                      "--username XXXXXXXX", 
                      "--tenant XXXXXXXX",
                      "--password XXXXXXXX")
        system(CMD)
}

list_testsongs <- function(){
        CMD <- c("az", "storage", "blob", "list",
                 "-c", Sys.getenv("CONTAINER_BLOBS_TEST"),
                 "--account-name", Sys.getenv("STORAGE_NAME"),
                 "--account-key", Sys.getenv("STORAGE_KEY"),
                 "|", "grep name", "|", "awk -F '[\"]' '{print $4 }'", 
                 "|", "grep -E \"*\\.wav$\""
        )
        CMD <- paste0(CMD, collapse=" ")
        system(CMD, intern=TRUE)
}

list_available_models <- function(){
        CMD <- c("az", "storage", "blob", "list",
                 "-c", Sys.getenv("CONTAINER_BLOBS_MODEL"),
                 "--account-name", Sys.getenv("STORAGE_NAME"),
                 "--account-key", Sys.getenv("STORAGE_KEY"),
                 "|", "grep name", "|", "awk -F '[\"]' '{print $4 }'", 
                 "|", "grep -E \"*\\.model$\""
        )
        CMD <- paste0(CMD, collapse=" ")
        system(CMD, intern=TRUE)
}

download_model_from_storage_container <- function(blobname, modelpath){
        CMD <- c("az", "storage", "blob", "download",
                 "-c", Sys.getenv("CONTAINER_BLOBS_MODEL"),
                 "--account-name", Sys.getenv("STORAGE_NAME"),
                 "--account-key", Sys.getenv("STORAGE_KEY"),
                 "-n", blobname, "-f", modelpath
                )
        CMD <- paste0(CMD, collapse=" ")
        system(CMD, intern=TRUE)
}

download_if_model_doesnt_exist <- function(modelname){
        modelpath <- file.path("/home/shiny/models", modelname)
        if( !file.exists(modelpath)){
               download_model_from_storage_container(modelname, modelpath)
        }
}

download_song_from_storage_container <- function(blobname, modelpath){
        CMD <- c("az", "storage", "blob", "download",
                 "-c", Sys.getenv("CONTAINER_BLOBS_TEST"),
                 "--account-name", Sys.getenv("STORAGE_NAME"),
                 "--account-key", Sys.getenv("STORAGE_KEY"),
                 "-n", blobname, "-f", modelpath
        )
        CMD <- paste0(CMD, collapse=" ")
        system(CMD, intern=TRUE)
}

download_if_song_doesnt_exist <- function(songname){
        songpath <- file.path("/home/shiny/songs", songname)
        if( !file.exists(songname)){
                download_song_from_storage_container(songname, songpath)
        }
}

get_audio_mfcc_matrix <- function(path){
        readWave(path) %>% 
                melfcc(numcep=40) 
}

predict_song <- function(songname, modelname){
        songname <- paste0(songname, ".wav")
        download_if_song_doesnt_exist(songname)
        songpath <- file.path("/home/shiny/songs", songname)
        
        download_if_model_doesnt_exist(modelname)
        modelpath <- file.path("/home/shiny/models", modelname) 
        model_object <- xgb.load(modelpath)
        
        songpath %>%
                get_audio_mfcc_matrix() %>%
                predict(model_object, .) %>%
                mean() %>%
                `<`(., 0.5) %>% 
                ifelse(., "beatles", "stones")
}
