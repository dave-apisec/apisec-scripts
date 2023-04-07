## TODO:
##
## Jenkins:
##
## 1. In Jenkins, create a new "Freestyle Project" 
## 2. In the Configurations section, check the box: "This project is parameterized"
##     2a. The parameters used are as follows:
##     2b. ['baseURL', 'scannerName', 'swaggerHubURL', 'setTier']
##     2c. Set these default values for now
##     2d. ['http://netbanking.apisec.ai:8080/', 'CVS-VPC-Alpha', 'gs://owasp-netbanking/NetBankingAPI.json', 'Master']
## 3. Under "Build Steps" add a step for "Execute Shell" 
## 4. Add this script to the "Command" field
## 5. Change the 6 instances of the word "REDACTED" to the correct password for this user 
## 6. Run the Jenkins job to validate that the script runs with these test values 
##
##

## ===== Fetch API Specification ===== 
## 
## First, the spec is fetched from Remote Storage (GCS) as a placeholder
## In other cases, this can be SwaggerHub or similar API Specification repo

gsutil cp "$swaggerHubURL" ./

## Let's set a name for the API. Customers can customize their naming convention, here we extract the API Name from "Title" field in the Spec

API_NAME=$(cat ./NetBankingAPI.json | jq --raw-output ".info.title" | sed 's/ //g')
echo $API_NAME > api_name.txt

## Check if the Project exists in APIsec
## This sets the value of $PROJECT_ID to "null" if the project doesn't exist

wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/jenkins-testing/configure-scripts/apisec-check-project-exists.sh -O apisec-check-project-exists.sh
PROJECT_ID=$(bash apisec-check-project-exists.sh --host https://cloud.apisec.ai --username testcicd@apisec.ai --password REDACTED --project $API_NAME)
echo $PROJECT_ID > project_id.txt

## ===== Register or Update API Specification =====
## 
## Using the APIsec API, update the API Specification so that new playbooks can be generated if the spec has been modified

## Set ENVVARs
## May not need to do this if this is all in the same shell step in Jenkins 

PROJECT_ID=$(cat project_id.txt)
API_NAME=$(cat api_name.txt)

## Get the scripts
wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/jenkins-testing/apisec-project-register-fileupload.sh -O apisec-project-register-fileupload.sh
wget https://raw.githubusercontent.com/dave-apisec/apisec-scripts/jenkins-testing/apisec-project-update-fileupload.sh -O apisec-project-update-fileupload.sh

if [ "$PROJECT_ID" != "null" ]
then
	bash apisec-project-update-fileupload.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --openAPISpecFile "./NetBankingAPI.json"
else
	bash apisec-project-register-fileupload.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --openAPISpecFile "./NetBankingAPI.json"
fi

## We need a better way for the project to indicate it's done generating playbooks and stuff. For now we'll do a sleep.
sleep 30

## ===== Adjust Configurations =====
## Configure Project
API_NAME=$(cat api_name.txt)

## Configure Scanner

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/jenkins-testing/configure-scripts/apisec-configure-profile-scanner.sh
bash apisec-configure-profile-scanner.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --profileName ${setTier} --scannerName ${scannerName} --envName "Master"

## Configure Base URL

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/jenkins-testing/configure-scripts/apisec-configure-env-baseurl.sh
bash apisec-configure-env-baseurl.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --envName "Master" --baseUrl ${baseURL}

## Execute APIsec Scan

API_NAME=$(cat api_name.txt)

wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/jenkins-testing/apisec_job_invoke_script.sh -O apisec_job_invoke_script.sh
bash apisec_job_invoke_script.sh --host "https://cloud.apisec.ai" --username "testcicd@apisec.ai" --password "REDACTED" --project ${API_NAME} --profile ${setTier}  --emailReport false --reportType RUN_SUMMARY
