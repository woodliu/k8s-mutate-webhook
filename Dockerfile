FROM golang:1.12-alpine AS build 
ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN apk add git make openssl

WORKDIR /go/src/github.com/woodliu/k8s-mutate-webhook
ADD . .
RUN make test
RUN make app

FROM scratch
WORKDIR /app
COPY --from=build /go/src/github.com/woodliu/k8s-mutate-webhook/mutatepodimages .
COPY --from=build /go/src/github.com/woodliu/k8s-mutate-webhook/ssl ssl
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
CMD ["/app/mutatepodimages"]
