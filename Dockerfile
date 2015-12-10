FROM httpd:2.4

RUN apt-get install -y make

ENV TZDATA_RELEASE 2015g

COPY build.sh generate* ./

RUN ./build.sh

COPY ./zoneinfo* /usr/local/apache2/htdocs/
COPY htaccess.tzurl /usr/local/apache2/htdocs/

