SHELL:=/bin/bash
include .env

.PHONY: all clean tzdata tzrearguard zoneinfo website rsync rsync-outlook

TARGET=$(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

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
		curl -L $(TZDB_BASE_URL)tzdb-$(TZDB_VERSION).tar.lz | tar --lzip -xC tzdb

	cd tzdb/tzdb-$(TZDB_VERSION) && make rearguard_tarballs && \
		tar -zxf tzdata$(TZDB_VERSION)-rearguard.tar.gz -C ../tzdata$(TZDB_VERSION)-rearguard

vzicbuild:
	mkdir -p vzic && \
		curl -L --output vzic/vzic-master.zip https://github.com/libical/vzic/archive/master.zip && \
		unzip vzic/vzic-master.zip -d vzic


zoneinfo:
	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX="" make -B

	./vzic/vzic-master/vzic --pure --output-dir zoneinfo --url-prefix http://tzurl.org/zoneinfo && \
		./vzic/vzic-master/vzic --output-dir zoneinfo-outlook --url-prefix http://tzurl.org/zoneinfo-outlook

	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX=$(TZID_PREFIX) make -B

	./vzic/vzic-master/vzic --pure --output-dir zoneinfo-global --url-prefix http://tzurl.org/zoneinfo-global  && \
		./vzic/vzic-master/vzic --output-dir zoneinfo-outlook-global --url-prefix http://tzurl.org/zoneinfo-outlook-global

website:
	website/generate-available-ids.sh zoneinfo/ && \
		website/generate-directory-listing.sh zoneinfo/

tzalias:
	awk '/^Link/ {print $$3,"="$$2}' tzdb/tzdata$(TZDB_VERSION)-rearguard/backward > tz.alias

upload:
	aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read zoneinfo-global s3://tzurl/zoneinfo-global
	aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read zoneinfo-outlook-global s3://tzurl/zoneinfo-outlook-global
	aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read zoneinfo-outlook s3://tzurl/zoneinfo-outlook
	aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read zoneinfo s3://tzurl/zoneinfo

rsync:
	rsync -av --delete --copy-links zoneinfo $(TARGET) && \
		rsync -av --delete --copy-links zoneinfo-global $(TARGET)

rsync-outlook:
	rsync -av --delete --copy-links zoneinfo-outlook $(TARGET) && \
		rsync -av --delete --copy-links zoneinfo-outlook-global $(TARGET)
