# ocd-tools

This Dockerfile creates a base image with the tools necessary to run OCD such as Helmfile and adnanh/webhook. See the Dockerfile for the list of tools it holds. The OCD webhook projects use this as their base image. 

This docker image is built on [circleci](https://circleci.com/gh/ocd-scm/ocd-tools) then pushed to [hub.docker.com](https://hub.docker.com/r/simonmassey/ocd-tools/). 

## See Also

The [ocd-meta wiki](https://github.com/ocd-scm/ocd-meta/wiki)
