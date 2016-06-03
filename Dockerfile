FROM httpd:2.4

RUN apt-get update && apt-get install -y --no-install-recommends make wget gcc pkg-config libglib2.0-dev

ENV TZDATA_RELEASE 2016c

WORKDIR /usr/local/apache2/htdocs

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

COPY build.sh generate* Makefile *.c *.h htaccess.tzurl index.html ./

RUN ./build.sh && mv htaccess.tzurl .htaccess

#VOLUME ["/usr/local/apache2"]
