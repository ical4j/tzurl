SHELL:=/bin/bash
include .env

.PHONY: all clean tzdata tzrearguard zoneinfo website rsync rsync-outlook

TARGET=$(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

all: zoneinfo

clean:
	rm -rf tzdb/tzdata$(TZDB_VERSION)/ && \
		rm -rf tzdb/tzdata$(TZDB_VERSION)-rearguard/ && \
		rm -rf tzdb/tzdb-$(TZDB_VERSION)/

tzdata:
	mkdir -p tzdb/tzdata$(TZDB_VERSION) && \
		curl -L $(TZDB_BASE_URL)tzdata$(TZDB_VERSION).tar.gz | tar -zxC tzdb/tzdata$(TZDB_VERSION)

tzrearguard:
	mkdir -p tzdb/tzdata$(TZDB_VERSION)-rearguard && \
		curl -L $(TZDB_BASE_URL)tzdb-$(TZDB_VERSION).tar.lz | tar --lzip -xC tzdb

	cd tzdb/tzdb-$(TZDB_VERSION) && make rearguard_tarballs && \
		tar -zxf tzdata$(TZDB_VERSION)-rearguard.tar.gz -C ../tzdata$(TZDB_VERSION)-rearguard

vzicbuild:
	rm -rf vzic/vzic-master && mkdir -p vzic && \
		curl -L --output vzic/vzic-master.zip https://github.com/libical/vzic/archive/master.zip && \
		unzip vzic/vzic-master.zip -d vzic


zoneinfo: tzdata tzrearguard
	rm -rf http https && mkdir -p http https

	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX="" make -B

	./vzic/vzic-master/vzic --pure --output-dir http/zoneinfo --url-prefix http://www.tzurl.org/zoneinfo && \
		./vzic/vzic-master/vzic --output-dir http/zoneinfo-outlook --url-prefix http://www.tzurl.org/zoneinfo-outlook

	./vzic/vzic-master/vzic --pure --output-dir https/zoneinfo --url-prefix https://www.tzurl.org/zoneinfo && \
		./vzic/vzic-master/vzic --output-dir https/zoneinfo-outlook --url-prefix https://www.tzurl.org/zoneinfo-outlook

	cd vzic/vzic-master && \
		OLSON_DIR=$(OLSON_DIR) PRODUCT_ID="$(PRODUCT_ID)" TZID_PREFIX=$(TZID_PREFIX) make -B

	./vzic/vzic-master/vzic --pure --output-dir http/zoneinfo-global --url-prefix http://www.tzurl.org/zoneinfo-global  && \
		./vzic/vzic-master/vzic --output-dir http/zoneinfo-outlook-global --url-prefix http://www.tzurl.org/zoneinfo-outlook-global

	./vzic/vzic-master/vzic --pure --output-dir https/zoneinfo-global --url-prefix https://www.tzurl.org/zoneinfo-global  && \
		./vzic/vzic-master/vzic --output-dir https/zoneinfo-outlook-global --url-prefix https://www.tzurl.org/zoneinfo-outlook-global

website: zoneinfo
	website/generate-available-ids.sh http/zoneinfo && \
		website/generate-directory-listing.sh http/zoneinfo

	website/generate-available-ids.sh http/zoneinfo-outlook && \
		website/generate-directory-listing.sh http/zoneinfo-outlook

	website/generate-available-ids.sh https/zoneinfo && \
		website/generate-directory-listing.sh https/zoneinfo

	website/generate-available-ids.sh https/zoneinfo-outlook && \
		website/generate-directory-listing.sh https/zoneinfo-outlook

tzalias:
	awk '/^Link/ {print $$3,"="$$2}' tzdb/tzdata$(TZDB_VERSION)-rearguard/backward > tz.alias

upload:
	AWS_PROFILE=$(AWS_PROFILE) aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read https/zoneinfo-global s3://www.tzurl/zoneinfo-global
	AWS_PROFILE=$(AWS_PROFILE) aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read https/zoneinfo-outlook-global s3://www.tzurl/zoneinfo-outlook-global
	AWS_PROFILE=$(AWS_PROFILE) aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read https/zoneinfo-outlook s3://www.tzurl/zoneinfo-outlook
	AWS_PROFILE=$(AWS_PROFILE) aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read https/zoneinfo s3://www.tzurl/zoneinfo

	AWS_PROFILE=$(AWS_PROFILE) aws s3 sync --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read website/images s3://www.tzurl/images
	AWS_PROFILE=$(AWS_PROFILE) aws s3 cp --endpoint=https://sgp1.digitaloceanspaces.com --acl public-read website/index.html s3://www.tzurl/

rsync:
	rsync -av --delete --copy-links https/zoneinfo $(TARGET) && \
		rsync -av --delete --copy-links https/zoneinfo-global $(TARGET)

rsync-outlook:
	rsync -av --delete --copy-links https/zoneinfo-outlook $(TARGET) && \
		rsync -av --delete --copy-links https/zoneinfo-outlook-global $(TARGET)

build:
	docker build -t $(REGISTRY)/tzurl:amd64 --build-arg ARCH=amd64/ . && \
		docker build -t $(REGISTRY)/tzurl:arm64v8 --build-arg ARCH=arm64v8/ .

test: build
	#docker run --rm -it -e STATIC_HOST=localhost:8080 -p8080:80 ical4j/tzurl-nginx
	docker run --rm -it -p8080:80 $(REGISTRY)/tzurl

tag:
	echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker tag $(REGISTRY)/tzurl:amd64 $(REGISTRY)/tzurl:amd64-% && \
		echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker tag $(REGISTRY)/tzurl:arm64v8 $(REGISTRY)/tzurl:arm64v8-%

#	echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker tag $(REGISTRY)/tzurl $(REGISTRY)/tzurl:%

push:
	echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker push $(REGISTRY)/tzurl:amd64-% && \
		echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker push $(REGISTRY)/tzurl:arm64v8-% && \
		echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker manifest create $(REGISTRY)/tzurl:% --amend $(REGISTRY)/tzurl:amd64-% --amend $(REGISTRY)/tzurl:arm64v8-% && \
		echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker manifest push $(REGISTRY)/tzurl:%

#	echo $(TAGS) | tr "/," "-\n" | xargs -n1 -I % docker push $(REGISTRY)/tzurl:%
