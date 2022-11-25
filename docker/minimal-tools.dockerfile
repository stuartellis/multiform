ARG DOCKER_IMAGE_BASE=alpine:3.16.3
ARG TERRAFORM_VERSION=1.3.5
ARG MAKE_PKG_VERSION=4.3-r0
ARG JQ_PKG_VERSION=1.6-r1

#============ BASE ===========

FROM ${DOCKER_IMAGE_BASE} as base

ARG JQ_PKG_VERSION
ARG MAKE_PKG_VERSION

RUN apk update && \
    apk upgrade && \
    apk add jq=$JQ_PKG_VERSION && \
    apk add make=$MAKE_PKG_VERSION

#========== BUILDER ==========

FROM base AS builder

ARG TERRAFORM_VERSION
ARG TARGETARCH

RUN apk add curl

WORKDIR /usr/local/bin

RUN curl -L https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform\_$TERRAFORM_VERSION\_linux\_$TARGETARCH.zip -o terraform\_$TERRAFORM_VERSION\_linux\_$TARGETARCH.zip && \
    unzip terraform\_$TERRAFORM_VERSION\_linux\_$TARGETARCH.zip && \
    rm terraform\_$TERRAFORM_VERSION\_linux\_$TARGETARCH.zip

#=========== APP ============

FROM base AS app

RUN addgroup appusers \
  && adduser -s /bin/sh -D -H appuser appusers

COPY --from=builder --chown=appuser:appusers /usr/local/bin /usr/local/bin
WORKDIR /usr/local/bin
USER appuser
CMD ["terraform", "version"]
