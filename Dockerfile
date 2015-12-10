FROM httpd:2.4

ENV TZDATA_RELEASE 2015g

RUN ./build.sh

COPY ./zoneinfo* /usr/local/apache2/htdocs/
COPY htaccess.tzurl /usr/local/apache2/htdocs/

