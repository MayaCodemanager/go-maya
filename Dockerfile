# Build Gmaya in a stock Go builder container
FROM golang:1.11-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers

ADD . /go-maya
RUN cd /go-maya && make gmaya

# Pull Gmaya into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-maya/build/bin/gmaya /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["gmaya"]
