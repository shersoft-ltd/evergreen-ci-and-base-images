ARG RUNTIME
ARG VERSION

FROM node:${VERSION}

# Try and minimise active vulnerabilities by updating all OS packages
RUN apt-get update && \
    apt-get dist-upgrade --yes && \
    rm -rf /var/lib/apt/lists/*

COPY self-test.js /usr/local/bin/self-test.js
COPY self-test.sh /usr/local/bin/self-test
