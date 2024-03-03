# Installing sandboxed containers-operator on OKD

The documentation of 
[installation of sandboxed containers operator on OpenShift](https://access.redhat.com/documentation/en-us/openshift_sandboxed_containers/1.5/html-single/openshift_sandboxed_containers_user_guide/index) 
is a great place to get the understanding of how things work but there are a 
few things extra to know about to install on OKD.

## Background

The operator uses ordinary rpm-ostree to install the component. By default
the operator is configured to use `sandboxed-containers` but thats an
OpenShift specific extension which is pre-loaded in a local
repository.

## Enable the FCOS repo

On FCOS we want to install `kata-containers` instead, which isn't pre-loaded, and
therefore we need to enable the fcos repo. Edit the file 
`/etc/yum.repos.d/fedora.repo` and set `enabled=1` to enable the Fedora repo.

## Setting the extension name in the operator

After enabling the repo, we need the operator to use it. When creating the subscription,
add a configuration to the environment to set `SANDBOXED_CONTAINERS_EXTENSION`
to `kata-containers`:

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-sandboxed-containers-operator
  namespace: openshift-sandboxed-containers-operator
spec:
  channel: stable
  installPlanApproval: Automatic
  name: sandboxed-containers-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: sandboxed-containers-operator.v1.5.2
  config:
    env:
      - name: SANDBOXED_CONTAINERS_EXTENSION
        value: kata-containers
```

## Creating the KataConfig custom resource 

This works exactly the same in OpenShift and OKD, i.e. use the following resource:

```yaml
apiVersion: kataconfiguration.openshift.io/v1
kind: KataConfig
metadata:
  name: cluster-kataconfig
spec:
  checkNodeEligibility: false 
  logLevel: info
```

