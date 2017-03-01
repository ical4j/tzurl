# tzurl - zoneinfo in VTIMEZONE format

This project is a fork of the vzic project, which implements conversion of Olson tzdata
 into iCalendar [VTIMEZONE](https://tools.ietf.org/html/rfc2445#section-4.6.5) objects.

The original vzic readme is available [here](README.vzic).
Ultimately the conversion code is largely unchanged. This project adds the capability 
to serve the VTIMEZONE objects from an Apache web server.

## Running in Docker

A Docker image has been created from this project and can be run as follows:

`docker run --rm -it -p 80:80 benfortuna/tzurl`

### HAProxy

A docker-compose configuration is provided that will run Apache HTTPD behind an HAProxy
load balancer. This allows for scaling multiple Apache instances, etc. Examples follow.

    $ docker-compose build && docker-compose up # run a single httpd instance behind haproxy
    
    $ docker-compose scale tzurl=2 && docker-compose up # run two httpd instance load-balanced

### Syslog

RSyslog is supported in HAProxy. Examples below.

    $ docker-compose run -d -e RSYSLOG_DESTINATION=<syslog_host:port> haproxy && docker-compose up
    
    $ docker-compose scale tzurl=2 && docker-compose run --service-ports -d -e RSYSLOG_DESTINATION=<syslog_host:port> haproxy
    

### AWStats

