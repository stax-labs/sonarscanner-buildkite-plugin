FROM openjdk:22-jdk-slim

ARG SONAR_SCANNER_VERSION=${SONAR_SCANNER_VERSION:-4.8.1.3023}
ARG VERSION=${PLUGIN_VERSION}
ARG DESCRIPTION="Run sonar-scanner in Docker"
ARG VCS_URL="https://github.com/wayfair-incubator/sonarscanner-buildkite-plugin"

USER root

RUN apt-get update -y && \
  apt-get install -y \
  curl \
  nodejs \
  unzip && \
  apt-get clean all

RUN curl -o ./sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip && \
  unzip sonarscanner.zip && \
  rm sonarscanner.zip && \
  mv sonar-scanner-${SONAR_SCANNER_VERSION} /usr/lib/sonar-scanner && \
  ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
COPY docker/sonar-scanner.properties /usr/lib/sonar-scanner/conf/sonar-scanner.properties

COPY docker/entrypoints/entrypoint.sh /usr/bin/scanner

RUN useradd -m sonar

WORKDIR /workdir
RUN chown -R sonar:sonar /workdir

ENV SONAR_RUNNER_HOME=/usr/lib/sonar-scanner

USER sonar

ENTRYPOINT [ "scanner" ]

ARG BUILD_DATE
LABEL \
  com.wayfair.name="sonarscannerbuildkite/sonarscanner" \
  com.wayfair.build-date=${BUILD_DATE} \
  com.wayfair.description=${DESCRIPTION} \
  com.wayfair.vsc_url=${VCS_URL} \
  com.wayfair.maintainer="James Curtin <jacurtin@wayfair.com>" \
  com.wayfair.vendor="Wayfair LLC." \
  com.wayfair.version=${VERSION}
