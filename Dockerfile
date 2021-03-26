FROM golang AS builder

COPY . /go/src/github.com/rclone/rclone/
WORKDIR /go/src/github.com/rclone/rclone/

RUN \
  CGO_ENABLED=0 \
  make
RUN ./rclone version

# Begin final image
FROM alpine:latest

ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN apk --no-cache add ca-certificates fuse
# Install gsutil for kms usage
RUN apk add --update python \ 
                     curl \ 
                     which \ 
                     bash
RUN curl -sSL https://sdk.cloud.google.com | bash

COPY --from=builder /go/src/github.com/rclone/rclone/rclone /usr/local/bin/

RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone

ENTRYPOINT [ "rclone" ]

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
