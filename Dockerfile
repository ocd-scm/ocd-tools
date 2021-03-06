# This image provides tools for OCD. 
# The following packages are installed as latest available on centos7:
#  - git https://jwiegley.github.io/git-from-the-bottom-up/
#  - cowsay https://en.wikipedia.org/wiki/Cowsay
#  - jq  https://stedolan.github.io/jq/
#  - yq https://github.com/kislyuk/yq
# The following packages are downloaded and installed using an explict version number:
#  - hub 2.4.0 https://hub.github.com 
#  - oc 3.11.0 https://docs.openshift.org/latest/cli_reference/index.html
#  - git-secret 0.2.4 http://git-secret.io
#  - gpg 2.2.9 https://www.gnupg.org)
#  - helm 2.9.0 
#  - webhook 2.6.9

FROM openshift/base-centos7

MAINTAINER Simon Massey <simbo1905@60hertz.com>

# install tools via rpm
RUN yum install deltarpm -y && yum update -y && yum install epel-release -y && \
     yum install \
        git \
        jq \
        cowsay \
        python-pip -y && yum clean all -y && rm -rf /var/cache/yum

# install yq via pip
RUN pip install yq

# git-secret
RUN cd /tmp && wget -q https://bintray.com/sobolevn/rpm/download_file?file_path=git-secret-0.2.4-1.noarch.rpm -O /tmp/git-secret.rpm && \
    rpm -i /tmp/git-secret.rpm 

RUN yum-builddep -y gnupg2 && yum clean all -y && rm -rf /var/cache/yum

COPY install-gnupg22.sh /usr/local/bin 

RUN /usr/local/bin/install-gnupg22.sh

RUN rm -rf /opt/app-root/src/.gnupg && chown -R 1001 /opt/app-root/src

# needed to lookup random usr in /etc/password for git push https://docs.openshift.com/enterprise/3.1/creating_images/guidelines.html
RUN yum -y install nss_wrapper gettext && yum clean all -y && rm -rf /var/cache/yum

# hub
RUN cd /tmp && wget -q -O - https://github.com/github/hub/releases/download/v2.4.0/hub-linux-amd64-2.4.0.tgz | \
    tar zxf - && \
    mv $(find . -name hub) /usr/local/bin

# webhook 2.6.9
RUN cd /tmp && curl -L https://github.com/adnanh/webhook/releases/download/2.6.9/webhook-linux-amd64.tar.gz | tar xz && mv ./webhook-linux-amd64/webhook /usr/local/bin && rm -rf /tmp/webhook-linux-amd64

# helm 2.10.0
RUN  cd /tmp && curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-amd64.tar.gz | tar xz && mv /tmp/linux-amd64/helm /usr/local/bin/helm && rm -rf /tmp/linux-amd64

# helmfile 0.47.0
RUN cd /tmp && wget https://github.com/roboll/helmfile/releases/download/v0.47.0/helmfile_linux_amd64 && mv helmfile_linux_amd64 /usr/local/bin/helmfile && chmod +x /usr/local/bin/helmfile

# helmfile dependencies
RUN mkdir -p "$(helm home)/plugins" && \
    helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/futuresimple/helm-secrets

# oc
RUN cd /tmp && \
    wget -q -O - https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz | \
    tar zxf - && \
    mv $(find . -name oc) /usr/local/bin

RUN chgrp -R 0 /opt/app-root/src/.helm && chmod -R g+w /opt/app-root/src/.helm

RUN mkdir -p /opt/app-root/src/.gnupg && chown -R 1001 /opt/app-root/src/.gnupg && chmod -R go-rwx,u+w /opt/app-root/src/.gnupg

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
