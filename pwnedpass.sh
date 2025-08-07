#!/bin/bash

_DEF_SLEEPY_=0.25
_SLEEPY_="${_SLEEPY_:-${_DEF_SLEEPY_}}"

#
# returns mix of: too_short no_alpha no_digits no_mixcase no_symbols
pwdStrength()
{
  local _msg
  local _str
  local _rc=1

  _msg=""
  _str="${1}"

  ! [[ "${#_str}" -ge 1200 ]] && _msg="${_msg}too_short "
  ! [[ "${_str}" =~ [[:alpha:]] ]] && _msg="${_msg}no_alpha "
  ! [[ "${_str}" =~ [[:digit:]] ]] && _msg="${_msg}no_digits "
  ! { [[ "${_str}" =~ [A-Z] ]] && [[ "${_str}" =~ [a-z] ]]; } && _msg="${_msg}no_mixcase "
  ! [[ "${_str}" == *['!'@#\$%^\&*\(\)_+]* ]] && _msg="${_msg}no_symbols"

  echo -n "${_msg}" | sed 's/[[:space:]]*$//;s/\n//;' | tr -d '\n'
  #sed 's/[[:space:]]*$//;s/\n//;' <<<${_msg} | tr -d '\n'

  [[ -z "${_msg}" ]] && _rc=0;
  return ${_rc}
}

#
# main #{
#

_qualityCheck=false
_pwnedCheck=true

while getopts "hnQ" opt; do #{
  case $opt in
    n) _pwnedCheck="false" ;;
    Q) _qualityCheck="true" ;;
    h|*) cat <<-_OPTSEOF
  USAGE: ${0} [OPTIONS]

  OPTIONS

  -n:  skips pwned check via the pwnedpasswords.com API
  -Q:  perform quality checks (i.e., strength) on passwords
_OPTSEOF
         exit 1
  esac
done #}
shift $((OPTIND-1))

# process KeePassX txt output
if [ -z "${1}" ]; then
  echo "${0}: filename"
  exit -1
fi

grep Password: "${1}" | grep -v -E '(^#)' |sed 's/ //g;s/Password://g;/^$/d' | sort > pwdlist.txt

# prepare sha1 hashes
cp /dev/null sha1list.txt
lc=0

while read -r p
do
  lc=$(( lc + 1 ))
  # use coreutils format for dgst to normalize output for
  # LibreSSL and OpenSSL to be [:xdigit:][:space:]*<input file name>
  ps=$(echo -n "${p}" | openssl dgst -sha1 -r | cut -d\  -f1)
  hp1=$(echo "${ps}" | cut -c 1-5)
  hp2=$(echo "${ps}" | cut -c 6-)
  echo "${hp1}:${hp2}" >> sha1list.txt
  #
  # curl  -vvI https://api.pwnedpasswords.com/range/${hp1} 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
  #

  ${_pwnedCheck} && m=$(curl "https://api.pwnedpasswords.com/range/${hp1}" -o - 2>/dev/null |\
    grep -i "${hp2}") && echo "$(head -${lc} pwdlist.txt | tail -1) PWNED:: ${m}"

  ${_qualityCheck} && {
    _strmsg="$(pwdStrength "${p}")"
    case "${_strmsg}" in # too_short no_alpha no_digits no_mixcase no_symbols {
      "too_short no_alpha no_mixcase no_symbols") 
        [[ ${#p} -lt 18 ]] && echo "${p}: ${#p} < (18) && is only numeric. A:(${_strmsg})"
        ;;
      "too_short no_alpha no_mixcase") 
        [[ ${#p} -lt 18 ]] && echo "${p}: ${#p} < (18) && is only numeric symbols. J:(${_strmsg})"
        ;;
      "too_short no_digits no_mixcase no_symbols")
        [[ ${#p} -lt 17 ]] && echo "${p}: ${#p} < (17) && is only alpha (non-mixed). B:(${_strmsg})"
        ;;
      "too_short no_digits no_symbols")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha (mixed case). C:(${_strmsg})"
        ;;
      "too_short no_symbols")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha-numeric (mixed case). D:(${_strmsg})"
        ;;
      "too_short no_digits")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha symbols (mixed case). E:(${_strmsg})"
        ;;
      "too_short no_mixcase")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha-numeric symbols (non-mixed). F:(${_strmsg})"
        ;;
      "too_short no_mixcase no_symbols")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha-numeric (non-mixed). G:(${_strmsg})"
        ;;
      "too_short no_digits no_mixcase")
        [[ ${#p} -lt 14 ]] && echo "${p}: ${#p} < (14) && is only alpha symbols (non-mixed). H:(${_strmsg})"
        ;;
      "too_short")
        [[ ${#p} -lt 13 ]] && echo "${p}: ${#p} < (13) && is only alpha-numeric symbols (mixed case). I:(${_strmsg})"
        ;;
      *)
        echo "${p}: UNKNOWN: $(pwdStrength "${p}") Z:(${_strmsg})"
        ;;
    esac  #}
  }

  ${_pwnedCheck} && sleep "${_SLEEPY_}"
done <<<"$(cat pwdlist.txt)"

#
# done #}
#
