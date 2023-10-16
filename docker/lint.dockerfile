FROM golang:1.21.3 AS gobuilder

RUN go install github.com/shurcooL/markdownfmt@latest
RUN go install github.com/mvdan/sh/cmd/shfmt@latest

FROM amazoncorretto:21 AS amazoncorrettobuilder

RUN yum update -y && \
  yum install -y \
  tar \
  xz

ARG SCVERSION="stable"

RUN curl -o shellcheck.tar.xz \
  -L "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-${SCVERSION}.linux.x86_64.tar.xz" \
  && tar xf shellcheck.tar.xz \
  && mv "shellcheck-${SCVERSION}/shellcheck" /usr/bin/

FROM amazoncorretto:21

RUN yum update -y && \
  yum install -y \
  shadow-utils

COPY --from=amazoncorrettobuilder /usr/bin/shellcheck /usr/bin/
COPY --from=gobuilder /go/bin/* /usr/bin/
COPY docker/entrypoints/run_formatters.sh /usr/bin/run_formatters

RUN useradd -m sonar
USER sonar

WORKDIR /app

ENTRYPOINT [ "run_formatters" ]
