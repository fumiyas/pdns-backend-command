#!/bin/ksh

set -u

domain="${PDNS_BACKEND_DYNAMIC_HOSTS_DOMAIN-example.jp}"
network="${PDNS_BACKEND_DYNAMIC_HOSTS_NETWORK-192.168}"
ttl="${PDNS_BACKEND_DYNAMIC_HOSTS_TTL-3600}"

name_prefix="${PDNS_BACKEND_DYNAMIC_HOSTS_NAME_PREFIX-host-}"
name_separator="${PDNS_BACKEND_DYNAMIC_HOSTS_NAME_SEPARATOR--}"

## ======================================================================

domain_rev="in-addr.arpa"
network_tmp="$network."
while [[ -n $network_tmp ]]; do
  domain_rev="${network_tmp%%.*}.$domain_rev"
  network_tmp="${network_tmp#*.}"
done

## ======================================================================

read -r greeting

case "$greeting" in
"HELO	1")
  : OK
  ;;
*)
  echo "FAIL	$greeting"
  exit 1
  ;;
esac

echo "OK	$0"

## ======================================================================

while read -r type qname qclass qtype id ip garbage; do
  if [[ $qtype = @(A|ANY) ]] && [[ -z ${qname%%*.$domain} ]]; then
    name=""
    qname_tmp="${qname%%.$domain}$name_separator"
    qname_tmp="${qname_tmp#$name_prefix}"
    while [[ -n $qname_tmp ]]; do
      name="${qname_tmp%%$name_separator*}${name:+.$name}"
      qname_tmp="${qname_tmp#*$name_separator}"
    done
    echo "DATA	$qname	$qclass	A	$ttl	-1	$name.$domain_rev"
  fi
  if [[ $qtype = @(PTR|ANY) ]] && [[ -z ${qname%%*.$domain_rev} ]]; then
    name=""
    qname_tmp="${qname%%.$domain_rev}."
    while [[ -n $qname_tmp ]]; do
      name="${qname_tmp%%.*}${name:+$name_separator$name}"
      qname_tmp="${qname_tmp#*.}"
    done
    echo "DATA	$qname	$qclass	PTR	$ttl	-1	$name_prefix$name.$domain"
  fi

  echo "END"
done

