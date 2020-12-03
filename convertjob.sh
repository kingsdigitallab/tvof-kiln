#!/bin/bash

ACTION=$1
STATUS_PATH="kiln_out/jobs/convert.status"
LOG_PATH="kiln_out/jobs/convert.log"
STATUS_RESET=0
STATUS_RUNNING_REMOTELY=-100000000
STATUS_DIED=-1008
STATUS_SCHEDULED=-1000

case $ACTION in
  run | run_if_scheduled | reset| status)
    ;;
  *)
    echo "Runs conversion according to the job status shared with data_release django app."
    echo
    echo "Possible actions:"
    echo "  run: runs the conversion now. Unless conversion died or already running."
    echo "  run_if_scheduled: run the conversion if it's status is 'scheduled'."
    echo "  reset: reset status to 0. In case the job died or is scheduled."
    echo "  status: return the current job status"
    echo
    exit
    ;;
esac

if [ ! -w $STATUS_PATH ]; then
  echo "WARNING: job status file doesn't exist ($STATUS_PATH) or is not writable."
  exit 1
fi

status=`cat $STATUS_PATH`
# echo "Job status: $status"

function run() {
  # we update the status
  let status="$STATUS_RUNNING_REMOTELY - $BASHPID"
  echo "$status" > $STATUS_PATH
  # and run the job (and redirect to log file)
  echo "Job is scheduled. Starting execution..."
  ###
  date &> $LOG_PATH
  # then we clear the status
  # status=$STATUS_RESET
  let status="0 - $?"
  echo "End of conversion job"
}

if [[ "$ACTION" == "reset" ]]; then
  status="$STATUS_RESET"
elif [[ "$status" == "$STATUS_DIED" ]]; then
  echo "Last conversion job died."
elif [[ "$status" == "$STATUS_SCHEDULED" ]]; then
  # scheduled,
  if [[ "$ACTION" == "run_if_scheduled" ]]; then
    run
  fi
elif [[ "$status" == "$STATUS_RESET" ]]; then
  if [[ "$ACTION" == "run" ]]; then
    run
  fi
elif [ $status -lt $STATUS_RUNNING_REMOTELY ]; then
  # still running?
  let pid="$STATUS_RUNNING_REMOTELY - $status"

  if ps -p $pid > /dev/null
  then
     echo "Conversion ($pid) is still running"
  else
     echo "Conversion ($pid) died"
     status=$STATUS_DIED
  fi
fi

echo "$status" > $STATUS_PATH
echo "Done (Status: $status)"
