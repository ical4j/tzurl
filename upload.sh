#!/usr/bin/env bash
#scp -rp zoneinfo $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av --delete zoneinfo $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av --delete zoneinfo-outlook $SSH_USER@tzurl.org:tzurl.org

