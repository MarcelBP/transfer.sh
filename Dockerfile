# Default to Go 1.12
ARG GO_VERSION=1.12
FROM golang:${GO_VERSION}-alpine as build

# Necessary to run 'go get' and to compile the linked binary
RUN apk add git musl-dev

ADD . /go/src/github.com/MarcelBP/transfer.sh

WORKDIR /go/src/github.com/MarcelBP/transfer.sh

ENV GO111MODULE=on

# build & install server
RUN go get -u ./... && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags -a -tags netgo -ldflags '-w -extldflags "-static"' -o /go/bin/transfersh github.com/MarcelBP/transfer.sh

FROM scratch AS final

COPY --from=build  /go/bin/transfersh /go/bin/transfersh
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY ./credentials.json ./
COPY ./token.json /tmp/token.json

ENTRYPOINT ["/go/bin/transfersh", "--listener", ":8080"]

EXPOSE 8080
