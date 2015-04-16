#!/usr/bin/env bash
#scp -rp zoneinfo modularity@tzurl.org:tzurl.org
rsync -e ssh -av zoneinfo modularity@tzurl.org:tzurl.org
rsync -e ssh -av zoneinfo-outlook modularity@tzurl.org:tzurl.org

