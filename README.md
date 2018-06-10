# What?

Outputs of GET on simple paths like `/api` and `/apis/batch/v1`, collected on various versions of kubernetes.

# Why?

To help answer questions like "can I assume `verbs` was always there? When was it added?"

# How?

See [tools/](tools/) directory.
I started from openshift, not kubernetes, because it can be run as a convenient [all-in-one container](https://docs.openshift.org/3.7/getting_started/administrators.html#running-in-a-docker-container).
TODO: add kubernetes, [rancher](rancher.com), etc...
*PRs welcome!*

# License

[Apache License, Version 2.0](http://www.apache.org/licenses/).
