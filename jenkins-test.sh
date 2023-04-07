## ===== Fetch API Specification ===== 
## 
## First, the spec is fetched from Remote Storage (GCS) as a placeholder
## In other cases, this can be SwaggerHub or similar API Specification repo

gsutil cp "$swaggerHubURL" ./

## Extract the API Name from "Title" field in the Spec

API_NAME=$(cat ./NetBankingAPI.json | jq --raw-output ".info.title" | sed 's/ //g')
echo $API_NAME > api_name.txt

## Check if the Project exists in APIsec

wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/master/configure-scripts/apisec-check-project-exists.sh -O apisec-check-project-exists.sh
PROJECT_ID=$(bash apisec-check-project-exists.sh --host https://cloud.apisec.ai --username testcicd@apisec.ai --password REDACTED --project $API_NAME)
echo $PROJECT_ID > project_id.txt

## ===== Register or Update API Specification =====
## 
## Using the APIsec API, update the API Specification so that new playbooks can be generated if the spec has been modified

## Set ENVVARs

PROJECT_ID=$(cat project_id.txt)
API_NAME=$(cat api_name.txt)

## Get the scripts
wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/master/apisec-project-register-fileupload.sh -O apisec-project-register-fileupload.sh
wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/master/apisec-project-update-fileupload.sh -O apisec-project-update-fileupload.sh

if [ "$PROJECT_ID" != "null" ]
then
	bash apisec-project-update-fileupload.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --openAPISpecFile "./NetBankingAPI.json"
else
	bash apisec-project-register-fileupload.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --openAPISpecFile "./NetBankingAPI.json"
fi

## ===== Adjust Configurations =====
## Configure Project
API_NAME=$(cat api_name.txt)

## Configure Scanner

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/master/configure-scripts/apisec-configure-profile-scanner.sh
bash apisec-configure-profile-scanner.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --profileName ${setTier} --scannerName ${scannerName} --envName "Master"

## Configure Base URL

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/master/configure-scripts/apisec-configure-env-baseurl.sh
bash apisec-configure-env-baseurl.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --envName "Master" --baseUrl ${baseURL}

## Execute APIsec Scan

API_NAME=$(cat api_name.txt)

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/master/apisec_job_invoke_script.sh -O apisec_job_invoke_script.sh
bash apisec_job_invoke_script.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --profile ${setTier}  --emailReport false --reportType RUN_SUMMARY
