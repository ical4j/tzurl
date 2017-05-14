FROM httpd:2.4

RUN apt-get update && apt-get install -y --no-install-recommends make wget gcc pkg-config libglib2.0-dev awstats cron rsyslog

COPY awstats.conf /etc/awstats/

ENV TZDATA_RELEASE 2017a

WORKDIR /usr/local/apache2/htdocs

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

COPY build.sh generate* Makefile *.c *.h htaccess.tzurl index.html ./

RUN ./build.sh && mv htaccess.tzurl .htaccess

VOLUME /zoneinfo /zoneinfo-outlook /zoneinfo-global /zoneinfo-global-outlook

CMD /usr/sbin/cron && httpd-foreground
