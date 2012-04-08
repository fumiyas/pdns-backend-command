#!/bin/ksh

pdie()
{
  echo "$0: ERROR: $1"
  exit 1
}

## ======================================================================

a_q="host-1-22.example.jp"
a_d="DATA	$a_q	IN	A	3600	-1	22.1.168.192.in-addr.arpa"

{
  echo "HELO	1"
  echo "Q $a_q IN A -1 10.0.0.1"
} \
|./dynamic-hosts.ksh \
| {
  read line
  [[ -z ${line##OK	*} ]] \
    || pdie "Invalid greeting message or version: $line"
  read line
  [[ $line = $a_d ]] \
    || pdie "Invalid data: $line"
  read line
  [[ $line = "END" ]] \
    || pdie "Invalid end line: $line"
}

## ======================================================================

a_q="200.100.168.192.in-addr.arpa"
a_d="DATA	$a_q	IN	PTR	3600	-1	host-100-200.example.jp"

{
  echo "HELO	1"
  echo "Q $a_q IN PTR -1 1.1.1.1"
} \
|./dynamic-hosts.ksh \
| {
  read line
  [[ -z ${line##OK	*} ]] \
    || pdie "Invalid greeting message or version: $line"
  read line
  [[ $line = $a_d ]] \
    || pdie "Invalid data: $line"
  read line
  [[ $line = "END" ]] \
    || pdie "Invalid end line: $line"
}

