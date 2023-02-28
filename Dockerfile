# Use OpenShift golang builder image
FROM registry.ci.openshift.org/openshift/release:golang-1.18 AS builder

WORKDIR /workspace

COPY Makefile Makefile
COPY hack hack/
COPY PROJECT PROJECT
COPY go.mod go.mod
COPY go.sum go.sum
COPY main.go main.go
COPY api api/
COPY config config/
COPY controllers controllers/

RUN go mod download
# needed for docker build but not for local builds
RUN go mod vendor

RUN GOFLAGS="" make build

# Use OpenShift base image
FROM registry.ci.openshift.org/origin/4.10:base
WORKDIR /
COPY --from=builder /workspace/bin/manager .

RUN useradd  -r -u 499 nonroot
RUN getent group nonroot || groupadd -o -g 499 nonroot

USER 499:499
ENTRYPOINT ["/manager"]
