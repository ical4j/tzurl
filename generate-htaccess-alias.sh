#!/usr/bin/env bash
## An AWK script for reading the Olson backward compatibility file and generating an htaccess file
#
## Latest tzdata available here: ftp://elsie.nci.nih.gov/pub/
#
awk '/Link/ {print "RewriteRule","^(.*)"$3,"$1"$2,"[NC]"}' tzdata$TZDATA_RELEASE/backward >> htaccess.tzurl

# Remove rewrites that cause infinite loop..
sed -r -i.bak '/\*\)(Kwajalein)(Singapore)|(UCT)|(UTC)/d' htaccess.tzurl
