FROM alpine:3.15

LABEL maintainer="Mr-Javadian <https://github.com/Mr-Javadian>"

WORKDIR /honest-ui

ENV TZ=Asia/Tehran
ENV GIN_MODE=release

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

COPY build/honest-ui-${TARGETOS}-${TARGETARCH}${TARGETVARIANT} honest-ui

RUN apk update && apk add --no-cache bash tzdata ca-certificates nftables \
    && rm -rf /var/cache/apk/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && chmod +x /honest-ui/honest-ui

CMD ["./honest-ui"]