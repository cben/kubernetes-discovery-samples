# What?

Outputs of GET on simple paths like `/api` and `/apis/batch/v1`, collected on various versions of kubernetes.

(tip: openshift 3.x versions are derived from corresponding kubernetes 1.x)

TODO: add other kubernetes distros e.g. [rancher](rancher.com)...
*PRs welcome!*

## Direct GitHub Pages access

You can even try plugging a URL like <https://cben.github.io/kubernetes-discovery-samples/openshift-origin-v3.10.0/api>
as the endpoint into kuberentes client libraries!  There are some deviations:

- [ ] Paths like `api/v1` are implemented as directories so they all redirect to `api/v1/`.
- [ ] Some paths that gave HTTP 403 errors are served here as 200 OK.

and of course it's not a real API, you can run any actions...

If you're viewing this from GitHub Pages, it won't show you the list of  subdirectories, see <https://github.com/cben/kubernetes-discovery-samples/>

# Why?

To help answer questions like "can I assume `verbs` was always there? When was it added?"

# How?

See [tools/](tools/) directory.
I started from openshift, not kubernetes, simply because it can be run as a convenient [all-in-one container](https://docs.openshift.org/3.7/getting_started/administrators.html#running-in-a-docker-container).

## TODO: Custom Resource Definitions

Obviously I can't collect all CRDs, but I started to collect some weird ones (lowercase `kind`, punctuation in `plural` & `singular`...) under [custom-resources/](custom-resources/) dir.

- [ ] Currently these are just the `CustomResourceDefinition` objects, NOT yet reflected in discovery results!

A good place with many CRDs is https://github.com/operator-framework/community-operators

# License

[Apache License, Version 2.0](http://www.apache.org/licenses/).
