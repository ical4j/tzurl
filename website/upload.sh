#!/usr/bin/env bash
#scp -rp zoneinfo $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av --delete zoneinfo $SSH_USER@www2.tzurl.org:www2.tzurl.org
rsync -e ssh -av --delete zoneinfo-outlook $SSH_USER@www2.tzurl.org:www2.tzurl.org

