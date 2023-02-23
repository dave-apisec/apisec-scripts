#!/bin/bash
# Begin
#
#
#


TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profileName:,scannerName:,envName:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		            --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --profileName) PROFILE_NAME="$2"; shift;;                    
                    --scannerName) SCANNER_NAME="$2"; shift;;   
                    --envName) ENV_NAME="$2"; shift;;                                     
                    --) shift;;
             esac
             shift;
    done
    
if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

dto=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
PROJECT_ID=$(echo "$dto" | jq -r '.id')

echo $PROJECT_ID

# pdto=$(echo $dto |  tr -d ' ')

# data=$(curl -s --location --request GET "${FX_HOST}/api/v1/jobs/project-id/${PROJECT_ID}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC"  --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')

# prof_names=$(jq -r '.name' <<< "$data")
# prof_names_count=( $prof_names )
# prof_names_count=$(echo ${#prof_names_count[*]})


