FROM golang AS base
RUN apt-get update \
 && apt-get -y install zip

FROM base AS ytt
ARG YTT_REF=master
SHELL [ "/bin/bash", "-c" ]
RUN git clone https://github.com/k14s/ytt ./src/github.com/k14s/ytt \
 && export GOPATH=$PWD
WORKDIR /go/src/github.com/k14s/ytt
RUN git checkout ${YTT_REF}
RUN VERSION=$(if test "${YTT_REF}" == "master"; then git rev-parse HEAD | cut -c1-7; else echo "${YTT_REF}"; fi) \
 && sed -i -E "s/Version = \"[^\"]+\"/Version = \"${VERSION}\"/" pkg/cmd/version.go \
 && ./hack/build.sh \
 && cp ytt /
RUN /ytt version

FROM base AS kubeyaml
RUN go get github.com/chuckha/kubeyaml/cmd/kubeyaml \
 && cp /go/bin/kubeyaml /

FROM scratch AS final
COPY --from=ytt /ytt /
COPY --from=kubeyaml /kubeyaml /
ENTRYPOINT [ "/ytt" ]
CMD [ "--help" ]