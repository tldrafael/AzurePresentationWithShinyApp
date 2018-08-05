
library(tidyverse)
library(xgboost)
library(tuneR)
source("/home/app.train/utils.R")

audios_dir <- Sys.getenv("AUDIO_DIR")
modelname <- Sys.getenv("MODELNAME")

train_model <- train_model_from_songs_dir(audios_dir)
xgb.save(train_model, modelname)
upload_model(modelname)
