[iCal4j]: https://www.ical4j.org
[tzurl.org]: https://wwww.tzurl.org

# tzurl - zoneinfo in VTIMEZONE format

A public collection of timezone definitions in iCalendar 
[VTIMEZONE](https://tools.ietf.org/html/rfc2445#section-4.6.5) format.

## Overview

The primary aim of this project is to provide timezone definitions to support the [iCal4j] library. Whilst
iCal4j includes these definitions with each release, the public [tzurl.org] site provides updates that may
be used with any iCalej release.

## Usage

The published definitions may be used by any libray by following this basic URL format:

    <protocol>://tzurl.org/<tz_collection>/<tz_id>

where:

* protocol - either `http` or `https`
* tz_collection - one of the published collections, including `zoneinfo`, `zoneinfo-global`, `zoneinfo-outlook` and `zoneinfo-global-outlook`
* tz_id - a timezeone identifier, such as `America/Vancouver`

## Timezone Collections

The following collections are published on the [tzurl.org] website.

### zoneinfo

This is the default timezone collection, which includes all of the latest timezone updates, using a
timezone identifier in the following format:

    <region>/<city>

### zoneinfo-outlook

TBD.

### zoneinfo-global

TBD.

### zoneinfo-global-outlook

TBD.



## Build

### Docker

    docker build --tag tzurl .
    

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

