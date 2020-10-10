FROM httpd:latest

RUN apt-get update && apt-get install -y --no-install-recommends make curl ca-certificates gcc pkg-config libglib2.0-dev awstats cron rsyslog rsync

COPY awstats.conf /etc/awstats/

ENV TZDATA_RELEASE=2018g-rearguard TZDATA_BASE_URL=https://web.cs.ucla.edu/~eggert/tz/release/2018g/

WORKDIR /usr/local/apache2/htdocs

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

COPY images/ images/
COPY build.sh generate* Makefile *.c *.h htaccess.tzurl index.html ./

RUN ./build.sh && mv htaccess.tzurl .htaccess

VOLUME /zoneinfo /zoneinfo-outlook /zoneinfo-global /zoneinfo-global-outlook

CMD /usr/sbin/cron && httpd-foreground
