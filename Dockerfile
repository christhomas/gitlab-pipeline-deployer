FROM debian:stable-slim as build

LABEL maintainer="Christopher Thomas <chris.thomas@antimatter-studios.com>"

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/debian \
          $(lsb_release -cs) \
          stable" \
    && apt-get update \
    && apt-get install -y docker-ce \
    && apt-get clean \
    && rm -rf /var/cache/apt /var/lib/apt

FROM debian:stable-slim as image

COPY --from=build /usr/lib/x86_64-linux-gnu /usr/lib/
COPY --from=build /usr/bin/docker* /usr/bin/

RUN apt-get update \
    && apt-get install -y curl wget \
    && apt-get clean

# Note: Latest version of kubectl may be found at:
# https://storage.googleapis.com/kubernetes-release/release/stable.txt
ENV KUBE_LATEST_VERSION="v1.14.1"

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_LATEST_VERSION="v2.13.1"

ENV HELM=https://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz
ENV KUBECTL=https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl

# Note: Latest version of docker-compose may be found at:
# https://github.com/docker/compose/releases
ENV DOCKER_COMPOSE_LATEST_VERSION="1.21.2"
ENV DOCKER_COMPOSE=https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_LATEST_VERSION}/docker-compose-linux-x86_64

# Copy everything into place
RUN curl -L ${DOCKER_COMPOSE} > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

RUN curl -L ${KUBECTL} -o /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

RUN curl -L ${HELM} | tar xzO linux-amd64/helm > /usr/local/bin/helm
RUN chmod +x /usr/local/bin/helm

