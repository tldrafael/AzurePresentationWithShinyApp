
do_login_azure <- function(){
        CMD <- paste0("az login --service-principal",
                      "--username XXXXXXXX", 
                      "--tenant XXXXXXXX",
                      "--password XXXXXXXX")
        system(CMD)
}

list_trainsongs <- function(){
        CMD <- c("az", "storage", "blob", "list",
                 "-c", Sys.getenv("CONTAINER_BLOBS_TRAIN"),
                 "--account-name", Sys.getenv("STORAGE_NAME"),
                 "--account-key", Sys.getenv("STORAGE_KEY"),
                 "|", "grep name", "|", "awk -F '[\"]' '{print $4 }'", 
                 "|", "grep -E \"*\\.wav$\""
        )
        CMD <- paste0(CMD, collapse=" ")
        system(CMD, intern=TRUE)
}

create_trainjob <- function(train_beatles, train_stones, modelname){
        
        if( modelname==""){
                warning("Escreva um nome para o modelo!!")
                return("")
        }
        modelname <- paste0(modelname, ".model")
        
        new_job <- jsonlite::read_json("job_template.json")
        new_job$id <- paste0("job", round(as.numeric(Sys.time())))
        
        blob_url_base <- paste0("https://", 
                                Sys.getenv("STORAGE_NAME"), ".blob.core.windows.net/", 
                                Sys.getenv("CONTAINER_BLOBS_TRAIN") )
        
        train_beatles_url <- map_chr(train_beatles, ~paste0(blob_url_base, "/beatles-", .x, ".wav"))
        train_stones_url <- map_chr(train_stones, ~paste0(blob_url_base, "/stones-", .x, ".wav"))
        
        resource_files <- list()
        for( f in c(train_beatles_url, train_stones_url)){
                fname <- f %>% str_split("/") %>% unlist() %>% `[`(5)
                resource_files <- c(resource_files, list(list(blobSource=f, filePath=fname)))
        }
        
        new_job$jobManagerTask$resourceFiles <- resource_files
        
        env_variables <- list(
                list(name="STORAGE_NAME", value=Sys.getenv("STORAGE_NAME")),
                list(name="STORAGE_KEY", value=Sys.getenv("STORAGE_KEY")),
                list(name="CONTAINER_BLOBS_MODEL", value=Sys.getenv("CONTAINER_BLOBS_MODEL")),
                list(name="AUDIO_DIR", value=paste0("/mnt/batch/tasks/workitems/", new_job$id, "/job-1/taskjob/wd")),
                list(name="MODELNAME", value=modelname)
        )
        new_job$jobManagerTask$environmentSettings <- env_variables
        jsonlite::write_json(new_job, "/home/shiny/new_job.json", auto_unbox=TRUE, pretty=TRUE)
        
        credentials <- paste0(c("--account-name", Sys.getenv("BATCH_ACCOUNT_NAME"),
                                "--account-endpoint", Sys.getenv("BATCH_ACCOUNT_ENDPOINT"),
                                "--account-key", Sys.getenv("BATCH_ACCOUNT_KEY")),
                              collapse=" ")
        
        CMD <- paste0("az batch job create --json-file /home/shiny/new_job.json ", credentials)
        system(CMD)
}

