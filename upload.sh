#scp -rp zoneinfo modularity@tzurl.org:tzurl.org
rsync -e "ssh -o 'StrictHostKeyChecking no'" -av zoneinfo modularity@tzurl.org:tzurl.org
rsync -e "ssh -o 'StrictHostKeyChecking no'" -av zoneinfo-outlook modularity@tzurl.org:tzurl.org

