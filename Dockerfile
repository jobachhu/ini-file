# ini-file set/get/del in a container
#
# docker run --rm -it -v /tmp:/tmp bitnami/ini-file set -k "title" -v "A wonderful book" -s "My book" /tmp/my.ini
# docker run --rm -it -v /tmp:/tmp bitnami/ini-file get -k "title" -s "My book" /tmp/my.ini
# docker run --rm -it -v /tmp:/tmp bitnami/ini-file del -k "title" -s "My book" /tmp/my.ini
#

FROM golang:1.16-stretch as build

RUN apt-get update && apt-get install -y --no-install-recommends \
    git make upx \
    && rm -rf /var/lib/apt/lists/*

RUN go get -u \
        golang.org/x/lint/golint \
        golang.org/x/tools/cmd/goimports \
        && rm -rf $GOPATH/src/* && rm -rf $GOPATH/pkg/*


WORKDIR /go/src/app
COPY . .

RUN rm -rf out

RUN make

RUN upx --ultra-brute out/ini-file

FROM bitnami/minideb:stretch

COPY --from=build /go/src/app/out/ini-file /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/ini-file"]
