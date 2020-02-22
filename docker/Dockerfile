FROM golang AS base
RUN apt-get update \
 && apt-get -y install zip

FROM base AS build
ARG REF=master
SHELL [ "/bin/bash", "-c" ]
RUN git clone https://github.com/k14s/ytt ./src/github.com/k14s/ytt \
 && export GOPATH=$PWD
WORKDIR /go/src/github.com/k14s/ytt
RUN git checkout ${REF}
RUN VERSION=$(if test "${REF}" == "master"; then git rev-parse HEAD | cut -c1-7; else echo "${REF}"; fi) \
 && sed -i -E "s/Version = \"[^\"]+\"/Version = \"${VERSION}\"/" pkg/cmd/version.go \
 && ./hack/build.sh \
 && cp ytt /
RUN /ytt version

FROM scratch AS final
COPY --from=build /ytt /ytt
ENTRYPOINT [ "/ytt" ]
CMD [ "--help" ]