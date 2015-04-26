#!/usr/bin/env bash
rsync -av --delete zoneinfo ~/tzurl.org
rsync -av --delete zoneinfo-outlook ~/tzurl.org
cp htaccess.tzurl ~/tzurl.org/.htaccess
