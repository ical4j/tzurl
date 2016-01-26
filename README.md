# tzurl - zoneinfo in VTIMEZONE format

This project is a fork of the vzic project, which implements conversion of Olson tzdata into iCalendar [VTIMEZONE](https://tools.ietf.org/html/rfc2445#section-4.6.5) objects.

The original vzic readme is available [here](README.vzic).
Ultimately the conversion code is largely unchanged. This project adds the capability to serve the VTIMEZONE objects from an
Apache web server.

## Running in Docker

A Docker image has been created from this project and can be run as follows:

`docker run --rm -it -p 80:80 benfortuna/tzurl`

