FROM alpine:3.14 as builder

ARG OPENFORTIVPN_VERSION=v1.17.1

RUN apk add --no-cache \
        openssl-dev \
        ppp \
        ca-certificates \
        curl \
    && apk add --no-cache --virtual .build-deps \
        automake \
        autoconf \
        g++ \
        gcc \
        make \
    && mkdir -p "/usr/src/openfortivpn" \
    && cd "/usr/src/openfortivpn" \
    && curl -Ls "https://github.com/adrienverge/openfortivpn/archive/${OPENFORTIVPN_VERSION}.tar.gz" \
        | tar xz --strip-components 1 \
    && aclocal \
    && autoconf \
    && automake --add-missing \
    && ./configure --prefix=/usr --sysconfdir=/etc \
    && make \
    && make install \
    && apk del .build-deps

FROM alpine:3.14

RUN apk add --no-cache \
        ca-certificates \
        openssl \
        ppp \
        curl \
        su-exec \
        iptables

COPY --from=builder /usr/bin/openfortivpn /usr/bin/openfortivpn

# Copy runfiles
COPY start.sh /start.sh

# Set permissions
RUN chmod +x /start.sh

CMD [ "/start.sh" ]