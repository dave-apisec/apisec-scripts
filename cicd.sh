wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/master/apisec_job_invoke_script.sh?token=AVOLEQ4FVVPJJ3DPAME4JELBS56SI -O apisec_job_invoke_script.sh;bash apisec_job_invoke_script.sh --host https://cloud.apisec.ai --username testcicd@apisec.ai --password {Password} --project "Guest Token Exchange API v1" --profile Master --scanner Super_2 --emailReport true --reportType RUN_SUMMARY --fail-on-high-vulns true
