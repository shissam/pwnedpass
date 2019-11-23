#!/bin/bash

# process KeePassX txt output
if [ -z "${1}" ]; then
  echo ${0}: filename
  exit -1
fi

grep Password: ${1} |sed 's/ //g;s/Password://g;/^$/d' | sort > pwdlist.txt

# prepare sha1 hashes
cp /dev/null sha1list.txt
lc=0
for p in $(cat pwdlist.txt)
do
  lc=$(( ${lc} + 1 ))
  # use coreutils format for dgst to normalize output for
  # LibreSSL and OpenSSL to be [:xdigit:][:space:]*<input file name>
  ps=$(echo -n ${p} | openssl dgst -sha1 -r | cut -d\  -f1)
  hp1=$(echo ${ps} | cut -c 1-5)
  hp2=$(echo ${ps} | cut -c 6-)
  echo ${hp1}:${hp2} >> sha1list.txt
  m=$(curl https://api.pwnedpasswords.com/range/${hp1} -o - 2>/dev/null |\
    grep -i ${hp2})
  rc=${?}
  if [ ${rc} -eq 0 ]; then
    echo "$(head -${lc} pwdlist.txt | tail -1) ${m}"
  fi
  sleep 0.25
done
