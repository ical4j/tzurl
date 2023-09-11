#!/usr/bin/env bash
find $1 -mindepth 1 -type f -name *.ics| sort | cut -d / -f 2- | cut -d . -f 1 > $1/tz.availableIds
