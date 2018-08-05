
get_label_from_filename <- function(filename){
        str_replace(filename, "-.*", "")
}

get_musicname_from_filename <- function(filename){
        str_replace(filename, ".*-", "") %>%
                str_replace("\\.wav", "")
}

get_audio_mfcc_matrix <- function(path){
        readWave(path) %>% 
                melfcc(numcep=40) %>% 
                as_tibble() %>% 
                mutate(filename=basename(path),
                       label=get_label_from_filename(filename),
                       label_num=ifelse(label=="beatles", 0, 1),
                       musicname=get_musicname_from_filename(filename)
                       )
}

get_train_data <- function(train_paths){
        train_data <- map_df(train_paths, get_audio_mfcc_matrix)
        list(data=as.matrix(train_data[,1:40]), label=train_data$label_num)
}

train_model <- function(data){
        xgb_fit <- xgboost(data=data$data, label=data$label, 
                        nrounds=25, print_every_n=5, 
                        objective="binary:logistic",
                        subsample=0.25, eta=0.1
        )
        print("Training is finished")
        xgb_fit
}

train_model_from_songs_dir <- function(train_dir){
        train_dir %>% 
                list.files(pattern="\\.wav", full.names=TRUE) %>% 
                get_train_data() %>% 
                train_model()
}

save_model <- function(model, filepath){
        xgb.save(model, filepath) 
        upload_model(filepath)
}

do_login_azure <- function(){
        CMD <- paste0("az login --service-principal",
                      "--username XXXXXXXX", 
                      "--tenant XXXXXXXX",
                      "--password XXXXXXXX")
        system(CMD)
}


upload_model <- function(filepath){
        do_login_azure()
        
        system(paste0("az storage blob upload -c ", Sys.getenv("CONTAINER_BLOBS_MODEL"),
                      " --account-name ", Sys.getenv("STORAGE_NAME"),
                      " --account-key ", Sys.getenv("STORAGE_KEY"),
                      " -f ", filepath, " -n ", basename(filepath)))
}
