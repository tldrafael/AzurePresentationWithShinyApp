## examples of names
RESOURCE_GROUP='shinyapp'
STORAGE_NAME='shinystorage'
CONTAINER_BLOBS_TRAIN='trainsongs'
CONTAINER_BLOBS_TEST='testsongs'
CONTAINER_BLOBS_MODEL='models'

BATCH_ACCOUNT_NAME='toledobatch'
PLAN_NAME='toledoshiny'

API_APPNAME_TRAIN='toledoapitrain'
API_DOCKER_TRAIN='tldrafael/api_docker_train'
API_APPNAME_PRED='toledoapipred'
API_DOCKER_PRED='tldrafael/api_docker_pred'

JOB_DOCKER_TRAIN='tldrafael/job_docker_train'


az group create -l brazilsouth -n $RESOURCE_GROUP

## --- storage issues -----------------------

az storage account create -n $STORAGE_NAME -g $RESOURCE_GROUP
STORAGE_KEY=$( az storage account keys list -n $STORAGE_NAME -g $RESOURCE_GROUP | grep value | head -n1 | awk -F '["]' '{print $4}')
az storage container create -n $CONTAINER_BLOBS_TRAIN --account-name $STORAGE_NAME --account-key $STORAGE_KEY
az storage container create -n $CONTAINER_BLOBS_TEST --account-name $STORAGE_NAME --account-key $STORAGE_KEY
az storage container create -n $CONTAINER_BLOBS_MODEL --account-name $STORAGE_NAME --account-key $STORAGE_KEY

az storage blob upload-batch -d $CONTAINER_BLOBS_TRAIN -s data_last10 \
                                --account-name $STORAGE_NAME --account-key $STORAGE_KEY 

az storage blob upload-batch -d $CONTAINER_BLOBS_TEST -s data_last10 \
                                --account-name $STORAGE_NAME --account-key $STORAGE_KEY 

## --- web app issues ----------------------

az appservice plan create -n $PLAN_NAME -g $RESOURCE_GROUP --sku B1 --is-linux -l brazilsouth

az webapp create -n $API_APPNAME_TRAIN -p $PLAN_NAME -g $RESOURCE_GROUP -i $API_DOCKER_TRAIN 

az webapp config appsettings set -g $RESOURCE_GROUP -n $API_APPNAME_TRAIN --settings \
                                        RESOURCE_GROUP=$RESOURCE_GROUP \
                                        CONTAINER_BLOBS_TRAIN=$CONTAINER_BLOBS_TRAIN \
                                        CONTAINER_BLOBS_MODEL=$CONTAINER_BLOBS_MODEL \
                                        STORAGE_NAME=$STORAGE_NAME \
                                        STORAGE_KEY=$STORAGE_KEY \
                                        BATCH_ACCOUNT_NAME=$BATCH_ACCOUNT_NAME \
                                        BATCH_ACCOUNT_ENDPOINT=$BATCH_ACCOUNT_ENDPOINT \
                                        BATCH_ACCOUNT_KEY=$BATCH_ACCOUNT_KEY 
                                                

az webapp create -n $API_APPNAME_PRED -p $PLAN_NAME -g $RESOURCE_GROUP -i $API_DOCKER_PRED

az webapp config appsettings set -g $RESOURCE_GROUP -n $API_APPNAME_PRED --settings \
                                        RESOURCE_GROUP=$RESOURCE_GROUP \
                                        CONTAINER_BLOBS_TRAIN=$CONTAINER_BLOBS_TRAIN \
                                        CONTAINER_BLOBS_MODEL=$CONTAINER_BLOBS_MODEL \
                                        STORAGE_NAME=$STORAGE_NAME \
                                        STORAGE_KEY=$STORAGE_KEY \
                                        BATCH_ACCOUNT_NAME=$BATCH_ACCOUNT_NAME \
                                        BATCH_ACCOUNT_ENDPOINT=$BATCH_ACCOUNT_ENDPOINT \
                                        BATCH_ACCOUNT_KEY=$BATCH_ACCOUNT_KEY 
                                                
## --- job issues ----------------------

az batch account create -n $BATCH_ACCOUNT_NAME -g $RESOURCE_GROUP -l brazilsouth
BATCH_ACCOUNT_ENDPOINT=$( az batch account show -n $BATCH_ACCOUNT_NAME -g $RESOURCE_GROUP | grep accountEndpoint | awk -F '["]' '{print $4}')
BATCH_ACCOUNT_KEY=$( az batch account keys list -n $BATCH_ACCOUNT_NAME -g $RESOURCE_GROUP | grep $BATCH_ACCOUNT_NAME -A1 | grep primary | awk -F '["]' '{print $4}')

az batch pool create --json-file pool.json \
        --account-name $BATCH_ACCOUNT_NAME --account-key $BATCH_ACCOUNT_KEY --account-endpoint $BATCH_ACCOUNT_ENDPOINT
        

