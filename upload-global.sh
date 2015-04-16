#!/usr/bin/env bash
rsync -e ssh -av zoneinfo-global $SSH_USER@tzurl.org:tzurl.org
rsync -e ssh -av zoneinfo-outlook-global $SSH_USER@tzurl.org:tzurl.org

