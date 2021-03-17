SHELL:=/bin/bash
TZDB_BASE_URL?=http://www.iana.org/time-zones/repository/releases/
TZDB_VERSION?=2020b

OLSON_DIR?=$(PWD)/tzdb/tzdata$(TZDB_VERSION)-rearguard
PRODUCT_ID?=-//tzurl.org//NONSGML Olson $(TZDB_VERSION)//EN
TZID_PREFIX?=/tzurl.org/$(TZDB_VERSION)/

.PHONY: all tzdata tzrearguard zoneinfo

all: zoneinfo

clean:
	rm -rf tzdb/tzdata$(TZDB_VERSION)/ && \
		rm -rf tzdb/tzdata$(TZDB_VERSION)-rearguard/ && \
		rm -rf tzdb/tzdb-$(TZDB_VERSION)/ && \
		rm -rf vzic/vzic-master/

tzdata:
	mkdir -p tzdb/tzdata$(TZDB_VERSION) && \
		curl -L $(TZDB_BASE_URL)tzdata$(TZDB_VERSION).tar.gz | tar -zxC tzdb/tzdata$(TZDB_VERSION)

tzrearguard:
	mkdir -p tzdb/tzdata$(TZDB_VERSION)-rearguard && \
		curl -L $(TZDB_BASE_URL)tzdb-$(TZDB_VERSION).tar.lz | tar -zxC tzdb

	cd tzdb/tzdb-$(TZDB_VERSION) && make rearguard_tarballs && \
		tar -zxf tzdata$(TZDB_VERSION)-rearguard.tar.gz -C ../tzdata$(TZDB_VERSION)-rearguard

vzicbuild: tzrearguard
#	mkdir -p vzic && \
#		curl -L --output vzic/vzic-master.zip https://github.com/libical/vzic/archive/master.zip && \
#		unzip vzic/vzic-master.zip -d vzic


zoneinfo:
	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX="" make -B

	./vzic/vzic-master/vzic --pure --output-dir zoneinfo --url-prefix http://tzurl.org/zoneinfo && \
		./vzic/vzic-master/vzic --output-dir zoneinfo-outlook --url-prefix http://tzurl.org/zoneinfo-outlook

	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX=$(TZID_PREFIX) make -B

	./vzic/vzic-master/vzic --pure --output-dir zoneinfo-global --url-prefix http://tzurl.org/zoneinfo-global

tzalias:
	awk '/^Link/ {print $$3,"="$$2}' tzdb/tzdata$(TZDB_VERSION)-rearguard/backward > tz.alias