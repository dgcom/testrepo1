#!/usr/bin/env bash
set -o pipefail
set -o errexit
set -o nounset
# set -o xtrace

newline=$'\n'

# ps %cpu is total consumption divided by total runtime, so we use
# the second iteration of top here to get a clean current value:
lines=$(top -bcn2 \
  |awk '/^top -/ { p=!p } { if (!p) print }' \
  |tail -n +8
)

metrics=""
errors=""
while read -r line; do
  mem=$(echo "${line}" |awk '{print $9}')
  pid=$(echo "${line}" |awk '{print $1}')
  cpu=$(echo "${line}" |awk '{print $10}')
  cmd=$(echo "${line}" \
    |awk '{print $12}' \
    |sed 's@/\([[:digit:]u+]\)@-\1@g' \
    |awk -F'/' '{print $NF}' \
    |sed 's@[^[:alnum:]_-]@@g' \
    |sed 's@^[_-]@@g' \
    |sed 's@[_-]$@@g' \
  && true)

  if [ "${cmd}" = "" ] || [ "${cmd}" = "nginx:" ] || [ "${cmd}" = "1" ] || [ "${cmd}" = "0" ] || [ "${cmd}" = "62" ] || [ "${cmd}" = "10" ] || [ "${cmd}" = "u160" ]; then
    errors="${errors}# error: cmd='${cmd}', orig line='${line}'${newline}"
  fi

  metrics="${metrics}top_cpu_usage{process=\"${cmd}\",pid=\"${pid}\"} ${cpu}${newline}"
  metrics="${metrics}top_mem_usage{process=\"${cmd}\",pid=\"${pid}\"} ${mem}${newline}"
done <<< "${lines}"

metrics="${metrics}${errors}"
echo -e "${metrics}"

# push to the prometheus pushgateway
curl -noproxy "*" -X POST -H "Content-Type: text/plain" -data "${metrics}" http://pushgateway:9091/metrics/job/top/instance/machine
