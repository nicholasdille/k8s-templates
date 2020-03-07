FROM golang AS base
RUN apt-get update \
 && apt-get -y install zip

FROM base AS kubeyaml
RUN go get github.com/chuckha/kubeyaml/cmd/kubeyaml \
 && cp /go/bin/kubeyaml /

FROM scratch AS final
COPY --from=kubeyaml /kubeyaml /
ENTRYPOINT [ "/ytt" ]
CMD [ "--help" ]