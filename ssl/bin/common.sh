#!/bin/sh

#----------------------------------------------------------------------------
# 1. Common parameters
#
# Path to OpenSSL binary
#
OPENSSL=/usr/bin/openssl
#
# Path to rehash utility
#
REHASH=./c_rehash
#
# File extensions
#
KEY_EXT=key
CERT_EXT=crt
P12_EXT=p12
PEM_EXT=pem
REQ_EXT=req
SERIAL_EXT=srl
#
# Common certificate parameters
#
DAYS=3650
COUNTRY_CODE=RU
STATE_NAME=RU
LOCALITY_NAME=Lipetsk
ORGANIZATION_NAME=Russan_Post
UNIT_NAME=UFPS_GOCHS
#
# Base paths
#
ROOT=~/go/src/github.com/pprisn/aster4mchs/ssl
TEMP_PATH=${ROOT}/tmp
LOG_PATH=${ROOT}/logs
#
#----------------------------------------------------------------------------
# 2. Root certificate authority parameters
#
CA_PATH=${ROOT}/ca			# Root certificate path
CA_FNAME=ca					# Base file name
CA_CN=Lipetsk_UFPS_Certificate_Autority		# X.509 Common name

_CA_KEY=${TEMP_PATH}/${CA_FNAME}.${KEY_EXT}
_CA_CRT=${TEMP_PATH}/${CA_FNAME}.${CERT_EXT}
_CA_P12=${TEMP_PATH}/${CA_FNAME}.${P12_EXT}
_CA_PEM=${TEMP_PATH}/${CA_FNAME}.${PEM_EXT}

CA_KEY=${CA_PATH}/${CA_FNAME}.${KEY_EXT}
CA_CRT=${CA_PATH}/${CA_FNAME}.${CERT_EXT}
CA_P12=${CA_PATH}/${CA_FNAME}.${P12_EXT}
CA_PEM=${CA_PATH}/${CA_FNAME}.${PEM_EXT}
CA_SRL=${CA_PATH}/${CA_FNAME}.${SERIAL_EXT}
#
#----------------------------------------------------------------------------
# 3. Web server certificate parameters
#
SERVER_PATH=${ROOT}/www
SERVER_FNAME=server
SERVER_CN=localhost

_SERVER_KEY=${TEMP_PATH}/${SERVER_FNAME}.${KEY_EXT}
_SERVER_CRT=${TEMP_PATH}/${SERVER_FNAME}.${CERT_EXT}
_SERVER_REQ=${TEMP_PATH}/${SERVER_FNAME}.${REQ_EXT}
_SERVER_P12=${TEMP_PATH}/${SERVER_FNAME}.${P12_EXT}

SERVER_KEY=${SERVER_PATH}/${SERVER_FNAME}.${KEY_EXT}
SERVER_CRT=${SERVER_PATH}/${SERVER_FNAME}.${CERT_EXT}
SERVER_P12=${SERVER_PATH}/${SERVER_FNAME}.${P12_EXT}
#
#----------------------------------------------------------------------------
# 4. Client certificate parameters
#
CLIENT_PATH=${ROOT}/clients
REVOKED_PATH=${ROOT}/revoked

_CLIENT_KEY=${TEMP_PATH}/${CLIENT_NAME}.${KEY_EXT}
_CLIENT_CRT=${TEMP_PATH}/${CLIENT_NAME}.${CERT_EXT}
_CLIENT_REQ=${TEMP_PATH}/${CLIENT_NAME}.${REQ_EXT}
_CLIENT_P12=${TEMP_PATH}/${CLIENT_NAME}.${P12_EXT}

CLIENT_KEY=${CLIENT_PATH}/${CLIENT_NAME}.${KEY_EXT}
CLIENT_CRT=${CLIENT_PATH}/${CLIENT_NAME}.${CERT_EXT}
CLIENT_P12=${CLIENT_PATH}/${CLIENT_NAME}.${P12_EXT}

#
#----------------------------------------------------------------------------
# 5. Common procedures
#
started()  {
  echo
  echo ---------------------------------------------------------
  date +"Started at %Y-%m-%d %H:%M:%S"
}

all_done()  {
  echo
  date +"Finished at %Y-%m-%d %H:%M:%S"
}

error()  {
  echo "ERROR: $1"
  exit 1
}

run_openssl()  {
  echo
  echo "**** "${1}
  shift
  ${OPENSSL} $*
  if [ $? -ne 0 ]; then
    error "OpenSSL unexpected error"
  fi
}

make_dn()  {
  if [ -z "$1" ]; then
    error "Common name is missing";
  fi
  COMMON_NAME=$1
  DN="/C=${COUNTRY_CODE}/ST=${STATE_NAME}/L=${LOCALITY_NAME}/O=${ORGANIZATION_NAME}/OU=${UNIT_NAME}/CN=${COMMON_NAME}"
}

make_dne()  {
  if [ -z "$1" ]; then
    error "Common name is missing";
  fi
  if [ -z "$2" ]; then
    error "Common EMAILADDRESS is missing";
  fi
  COMMON_NAME=$1
  CLIENT_EMAIL=$2
  DN="/C=${COUNTRY_CODE}/ST=${STATE_NAME}/L=${LOCALITY_NAME}/O=${ORGANIZATION_NAME}/OU=${UNIT_NAME}/emailAddress=${CLIENT_EMAIL}/CN=${COMMON_NAME}"
}
