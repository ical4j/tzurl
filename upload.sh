#!/usr/bin/env bash
#scp -rp zoneinfo $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av zoneinfo $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av zoneinfo-outlook $SSH_USER@tzurl.org:tzurl.org

