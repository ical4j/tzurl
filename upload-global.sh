#!/usr/bin/env bash
rsync -e ssh -av --delete zoneinfo-global $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av --delete zoneinfo-outlook-global $SSH_USER@tzurl.org:tzurl.org

