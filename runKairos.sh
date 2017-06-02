#!/bin/bash

set -eux

export PORT_TELNET=${PORT_TELNET:-4242}
export PORT_HTTP=${PORT_HTTP:-8080}
export PORT_CARBON_TEXT=${PORT_CARBON_TEXT:-2003}
export PORT_CARBON_PICKLE=${PORT_CARBON_PICKLE:-2004}
export CASS_HOSTS=${CASS_HOSTS:-"localhost:9160"}
export REPFACTOR=${REPFACTOR:-1}
export READ_CONSISTENCY_DATA=${READ_CONSISTENCY_DATA:-ONE}
export WRITE_CONSISTENCY_DATA=${WRITE_CONSISTENCY_DATA:-QUORUM}
export READ_CONSISTENCY_INDEX=${READ_CONSISTENCY_INDEX:-ONE}
export READ_CONSISTENCY_INDEX=${WRITE_CONSISTENCY_INDEX:-QUORUM}


function main {
  while IFS=, read address; do
      while IFS=: read ip port; do
          until nc -w 5 -z $ip $port; do
              echo "Waiting for $ip:$port"
              sleep 3
          done
      done < <(echo $address)
  done < <(echo $CASS_HOSTS)
  echo "- env ------------------------------------------------------------------"
  env | sort
  echo "------------------------------------------------------------------------"
  echo "- kairosdb.properties --------------------------------------------------"
  /usr/sbin/envsubst < /tmp/kairosdb.properties > /opt/kairosdb/conf/kairosdb.properties
  cat /opt/kairosdb/conf/kairosdb.properties
  echo "------------------------------------------------------------------------"
  /opt/kairosdb/bin/kairosdb.sh run
}

main "$@"

