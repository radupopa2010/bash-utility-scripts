#!/bin/bash

# Script to restart kubectl jobs that make services running in a k8s cluster with a ClusterIP type
# available on localhost

# examoles of running the commnds manually

# make prometheus service availabe at http://localhost:9090
# kubectl -n monitoring-chaos port-forward svc/prometheus-simnet-kube-pro-prometheus 9090 &> /dev/null  &

set -eou pipefail

declare -A SERVICES
SERVICES['svc/prometheus-simnet-kube-pro-prometheus']=9090
SERVICES['svc/prometheus-simnet-kube-pro-alertmanager']=9093
SERVICES['svc/prometheus-simnet-grafana']=80

JOB_LOGS="jobs.log"
echo "" > "${JOB_LOGS}"

function forward_services {

  for svc in "${!SERVICES[@]}"; do
    forward_svc "${svc}"
  done

}

function forward_svc {
  local svc port
  svc=$1
  port=${SERVICES["${svc}"]}
  
  if is_port_forward_running "${port}" ; then
    restart_job "${svc}"
  else
    start_job "${svc}"
  fi
}

function is_port_forward_running {
  local port 
  port=${1}
  # shellcheck disable=SC2009
  ps aux | grep -qE "port-forward.*${port}$"
}

function restart_job {
  local port svc
  svc=${1}
  port=${SERVICES["${svc}"]}

  kill_previous_job "${svc}"
  start_job "${svc}"
}

function start_job {
  local port svc local_port
  svc=$1
  port=${SERVICES["${svc}"]}

  # cant listen on port 80 as normal user
  if [[ "${port}" == 80 ]] ; then
    local_port=9080
  else
    local_port="${port}"
  fi

  ensure kubectl -n monitoring-chaos port-forward "${svc}" "${local_port}:${port}" &>> "${JOB_LOGS}"  &
}

function ensure {
  if ! "$@" ; then 
    echo "Command $* failed"
    exit 1
  fi
}

function kill_previous_job {
  local port svc
  svc=${1}
  port=${SERVICES["${svc}"]}
  # shellcheck disable=SC2009
  job_pid=$(ps aux | grep -E "port-forward.*${port}$" | awk '{ print $2 }')
  kill "${job_pid}"
}

forward_services
sleep 2
cat "${JOB_LOGS}"
