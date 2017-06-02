#!/usr/bin/env bash
mkdir -p tzdata$TZDATA_RELEASE && curl -L http://www.iana.org/time-zones/repository/releases/tzdata$TZDATA_RELEASE.tar.gz | tar -zxC tzdata$TZDATA_RELEASE &&  make clean && make
./generate-zoneinfo.sh
./generate-zoneinfo-global.sh
./generate-htaccess-alias.sh
