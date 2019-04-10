FROM golang:1.12-alpine AS builder

RUN  mkdir -p "$GOPATH/src/gitlab.you-zhe.com/devops/git-sync"

ADD . "$GOPATH/src/gitlab.you-zhe.com/devops/git-sync"

RUN cd "$GOPATH/src/gitlab.you-zhe.com/devops/git-sync" && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOFLAGS="-mod=vendor" \
    go install --installsuffix "static"  -ldflags "-X $(go list -m)/pkg/version.VERSION=3.1.1" ./...

FROM alpine:3.4

COPY --from=builder /go/bin/git-sync /git-sync

RUN apk update --no-cache && apk add \
    ca-certificates \
    coreutils \
    git \
    openssh-client

RUN echo "git-sync:x:65533:65533::/tmp:/sbin/nologin" >> /etc/passwd

WORKDIR /tmp
USER git-sync:nobody
ENTRYPOINT ["/git-sync"]
