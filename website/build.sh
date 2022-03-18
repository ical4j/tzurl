#!/usr/bin/env bash
TZDATA_BASE_URL=${TZDATA_BASE_URL:-http://www.iana.org/time-zones/repository/releases/}
mkdir -p tzdata$TZDATA_RELEASE && curl -L ${TZDATA_BASE_URL}tzdata$TZDATA_RELEASE.tar.gz | tar -zxC tzdata$TZDATA_RELEASE &&  make clean && make
./generate-zoneinfo.sh
./generate-zoneinfo-global.sh
./generate-htaccess-alias.sh
